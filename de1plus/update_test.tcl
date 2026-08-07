#!/usr/local/bin/tclsh

##############################################################################
# update_test.tcl -- DRY-RUN de1app updater / diagnostic.
#
# Runs the SAME app-update sequence as start_app_update (updater.tcl):
# fetch the channel timestamp + manifest, work out which files differ, then
# download EACH file over the identical TclCurl transport and SHA-256 verify
# it against the manifest -- but it NEVER writes into the app tree, NEVER
# copies a file into place, and NEVER rewrites timestamp.txt / manifest.txt.
# It only writes a log and some throw-away temp downloads (which it deletes).
#
# Purpose: reproduce + diagnose an "app update" that fails while downloading a
# particular file (e.g. dui.tcl going stable->nightly). For every file it logs
# expected-vs-actual SHA + size, the HTTP status, the response headers the
# failing client actually saw (Content-Length / Content-Encoding / Content-Type
# and the CDN cache headers X-Cache / Age / CF-Cache-Status / ETag /
# Last-Modified), and -- on a mismatch -- the first bytes of what came back
# plus a second fetch to tell a stale/corrupt cache (same wrong bytes twice)
# apart from a truncated/flaky download (different bytes each time).
#
# USAGE (standalone, like appupdate.tcl -- needs undroidwish/wish on a tablet
# for TclCurl+tls; plain tclsh works too but falls back to Tcl http):
#
#   <wish> update_test.tcl                 # test ALL files in the remote manifest
#   <wish> update_test.tcl diff            # only files that differ from the LOCAL
#                                          #   manifest == exactly what the real
#                                          #   updater would fetch (fastest repro
#                                          #   of the customer's actual scenario)
#   <wish> update_test.tcl only dui.tcl    # only file(s) matching a glob pattern
#   <wish> update_test.tcl only *dui* *.tcl
#
# Channel override (default = nightly, since the reported bug is stable->nightly):
#   env DE1_UPDATE_CHANNEL = nightly | beta | stable
#
# The log is written to <data_directory>/update_test_log.txt AND to stdout.
##############################################################################

cd "[file dirname [info script]]/"
source "pkgIndex.tcl"
package require de1_updater

if {[file exists "de1plus.tcl"] == 1} {
    package provide de1plus 1.0
}

determine_if_android

package require sha256
catch { package require crc32 }
package require http 2.5
set ::_ut_has_tls 0
catch {
    package require tls 1.6
    ::http::register https 443 ::tls::socket
    set ::_ut_has_tls 1
}

# never let the shared updater/logging code think it is doing a real update
set ::app_updating 0
set ::settings(app_updates_beta_enabled) 2 ;# default nightly; overridden below

##############################################################################
# logging
##############################################################################
set ::_ut_logfile "[data_directory]/update_test_log.txt"
catch { file delete $::_ut_logfile }
set ::_ut_logchan ""
catch { set ::_ut_logchan [open $::_ut_logfile w] }

proc ulog {msg} {
    set line "[clock format [clock seconds] -format {%H:%M:%S}] $msg"
    catch { puts $line }
    if {$::_ut_logchan ne ""} {
        catch { puts $::_ut_logchan $line ; flush $::_ut_logchan }
    }
    # keep the GUI (if any) responsive
    catch { update }
}

proc ulog_sep {} { ulog "----------------------------------------------------------------------" }

##############################################################################
# argument parsing
##############################################################################
# modes: all (default) | diff | only <patterns...>
set ::_ut_mode "all"
set ::_ut_only_patterns {}
if {[llength $::argv] > 0} {
    set a0 [lindex $::argv 0]
    if {$a0 eq "diff"} {
        set ::_ut_mode "diff"
    } elseif {$a0 eq "all"} {
        set ::_ut_mode "all"
    } elseif {$a0 eq "only"} {
        set ::_ut_mode "only"
        set ::_ut_only_patterns [lrange $::argv 1 end]
        if {[llength $::_ut_only_patterns] == 0} { set ::_ut_only_patterns {dui.tcl} }
    }
}

##############################################################################
# channel selection (default nightly)
##############################################################################
set ::_ut_channel "nightly"
if {[info exists ::env(DE1_UPDATE_CHANNEL)]} {
    set ::_ut_channel $::env(DE1_UPDATE_CHANNEL)
}
switch -- $::_ut_channel {
    stable  { set progname "de1plus"    ; set ::settings(app_updates_beta_enabled) 0 }
    beta    { set progname "de1beta"    ; set ::settings(app_updates_beta_enabled) 1 }
    default { set progname "de1nightly" ; set ::settings(app_updates_beta_enabled) 2 ; set ::_ut_channel "nightly" }
}

# match start_app_update's host choice
if {$::_ut_has_tls} {
    set host  "https://fast.decentespresso.com"
} else {
    set host  "http://fast.decentespresso.com"
}

##############################################################################
# ut_fetch: download one URL to $fn, capturing full diagnostics. Uses the SAME
# TclCurl options as updater.tcl's decent_http_get_to_file (so it reproduces the
# real update transport exactly), and falls back to Tcl http when TclCurl is
# absent. Returns a dict of diagnostics; does NOT verify SHA (caller does).
##############################################################################
proc _ut_hdr_scan {hdrs key} {
    # return the value of the LAST occurrence of header $key (case-insensitive)
    # across possibly several header blocks (redirects). "" if absent.
    set val ""
    foreach line [split $hdrs "\n"] {
        set line [string trimright $line "\r"]
        if {[regexp -nocase "^${key}:\\s*(.*)$" $line -> v]} { set val [string trim $v] }
    }
    return $val
}
proc _ut_status_lines {hdrs} {
    set out {}
    foreach line [split $hdrs "\n"] {
        set line [string trim $line]
        if {[string match "HTTP/*" $line]} { lappend out $line }
    }
    return $out
}

proc ut_fetch {url fn} {
    array set R {ok 0 transport "" httpcode "" statusline "" bytes 0 \
                 contentlength "" contenttype "" contentencoding "" \
                 xcache "" age "" cfcache "" etag "" lastmod "" err ""}
    catch { file delete $fn }

    if {![catch {package require TclCurl}]} {
        set R(transport) "TclCurl"
        set hdrs ""
        set hdl [curl::init]
        if {[catch {
            $hdl configure -url $url -file $fn -useragent "mer454" \
                -connecttimeout 20 -lowspeedlimit 1 -lowspeedtime 60 \
                -followlocation 1 -failonerror 1 -headervar hdrs
            set _ca "[homedir]/allcerts.pem"
            if {[file exists $_ca]} {
                $hdl configure -sslverifypeer 1 -cainfo $_ca
            }
            $hdl perform
            set R(ok) 1
        } err]} {
            set R(err) $err
        }
        catch { set R(httpcode) [$hdl getinfo responsecode] }
        if {$R(httpcode) eq ""} { catch { set R(httpcode) [$hdl getinfo httpcode] } }
        catch { $hdl cleanup }
        set sl [_ut_status_lines $hdrs]
        set R(statusline)      [lindex $sl end]
        set R(contentlength)   [_ut_hdr_scan $hdrs "Content-Length"]
        set R(contenttype)     [_ut_hdr_scan $hdrs "Content-Type"]
        set R(contentencoding) [_ut_hdr_scan $hdrs "Content-Encoding"]
        set R(xcache)          [_ut_hdr_scan $hdrs "X-Cache"]
        set R(age)             [_ut_hdr_scan $hdrs "Age"]
        set R(cfcache)         [_ut_hdr_scan $hdrs "CF-Cache-Status"]
        set R(etag)            [_ut_hdr_scan $hdrs "ETag"]
        set R(lastmod)         [_ut_hdr_scan $hdrs "Last-Modified"]
    } else {
        set R(transport) "Tcl-http"
        set out ""
        if {[catch {
            set out [open $fn w]
            fconfigure $out -blocking 1 -translation binary
            ::http::config -useragent "mer454"
            set tok [::http::geturl $url -channel $out -blocksize 65536 -binary 1 -keepalive 0 -timeout 60000]
            close $out ; set out ""
            catch { set R(httpcode) [::http::ncode $tok] }
            catch {
                array set meta [::http::meta $tok]
                foreach {k v} [array get meta] {
                    switch -nocase -- $k {
                        Content-Length   { set R(contentlength) $v }
                        Content-Type     { set R(contenttype) $v }
                        Content-Encoding { set R(contentencoding) $v }
                        X-Cache          { set R(xcache) $v }
                        Age              { set R(age) $v }
                        CF-Cache-Status  { set R(cfcache) $v }
                        ETag             { set R(etag) $v }
                        Last-Modified    { set R(lastmod) $v }
                    }
                }
            }
            set R(statusline) "[::http::code $tok]"
            if {[::http::error $tok] ne ""} { set R(err) [::http::error $tok] }
            if {[::http::status $tok] eq "ok" && $R(httpcode) == 200} { set R(ok) 1 }
            ::http::cleanup $tok
        } err]} {
            catch { if {$out ne ""} { close $out } }
            set R(err) $err
        }
    }

    if {[file exists $fn]} { set R(bytes) [file size $fn] }
    return [array get R]
}

# read the first N bytes of a file (to reveal an HTML error page etc.)
proc _ut_head_bytes {fn n} {
    set data ""
    catch {
        set f [open $fn]
        fconfigure $f -translation binary
        set data [read $f $n]
        close $f
    }
    # make it one-line printable
    regsub -all {[[:cntrl:]]} $data " " data
    return [string range $data 0 [expr {$n-1}]]
}

##############################################################################
# 1. banner + environment
##############################################################################
ulog_sep
ulog "de1app UPDATE DRY-RUN / DIAGNOSTIC (no local files will be modified)"
ulog_sep
ulog "mode            : $::_ut_mode [expr {$::_ut_mode eq {only} ? $::_ut_only_patterns : {}}]"
ulog "channel         : $::_ut_channel  (progname=$progname)"
ulog "host            : $host   (tls=[expr {$::_ut_has_tls ? {yes} : {no, using http}}])"
ulog "homedir         : [homedir]"
ulog "data_directory  : [data_directory]"
ulog "android=$::android undroid=$::undroid has_bluetooth=[ifexists ::has_bluetooth 0] ios=[ifexists ::ios 0]"
ulog "TclCurl present : [expr {![catch {package require TclCurl}]}]"
ulog "log file        : $::_ut_logfile"

##############################################################################
# 2. timestamp
##############################################################################
ulog_sep
set url_timestamp "$host/download/sync/$progname/timestamp.txt"
ulog "GET $url_timestamp"
set remote_timestamp ""
catch { set remote_timestamp [string trim [decent_http_get $url_timestamp]] }
set local_timestamp [string trim [read_file "[homedir]/timestamp.txt"]]
ulog "remote timestamp: '$remote_timestamp'"
ulog "local  timestamp: '$local_timestamp'"
if {$remote_timestamp eq ""} {
    ulog "FATAL: could not fetch remote timestamp -- network/DNS/TLS problem, aborting."
    catch { close $::_ut_logchan }
    return
}

##############################################################################
# 3. manifest (same integrity checks as start_app_update)
##############################################################################
ulog_sep
set url_manifest_gz "$host/download/sync/$progname/manifest.gz"
ulog "GET $url_manifest_gz"
set remote_manifest_gz {}
set remote_manifest {}
catch { set remote_manifest_gz [decent_http_get $url_manifest_gz] }
ulog "manifest.gz bytes: [string length $remote_manifest_gz]"
if {[catch { set remote_manifest [zlib gunzip $remote_manifest_gz] } gzerr]} {
    ulog "FATAL: manifest.gz did not gunzip: $gzerr"
    ulog "  first 200 bytes of what we got: '[string range $remote_manifest_gz 0 200]'"
    catch { close $::_ut_logchan }
    return
}
set mlen [llength $remote_manifest]
set mmod [expr {$mlen % 4}]
ulog "manifest gunzip list length: $mlen  (% 4 = $mmod  -> [expr {$mmod==0 ? {OK} : {CORRUPT, not a multiple of 4!}}])"
if {$mmod != 0 || $mlen == 0} {
    ulog "FATAL: remote manifest is corrupt (see start_app_update's same check)."
    ulog "  first 500 chars: '[string range $remote_manifest 0 500]'"
    catch { close $::_ut_logchan }
    return
}
set nfiles [expr {$mlen / 4}]
ulog "remote manifest describes $nfiles files"

# report the dui.tcl entry specifically (the known-failing file)
foreach {fnm fsz fmt fsh} $remote_manifest {
    if {$fnm eq "dui.tcl" || [string match "*/dui.tcl" $fnm]} {
        ulog "  >> remote manifest entry for '$fnm': size=$fsz mtime=$fmt sha=$fsh"
    }
}

##############################################################################
# 4. build the LOCAL manifest map (for 'diff' mode + reporting), exactly like
#    start_app_update does.
##############################################################################
set local_manifest ""
if {[file exists "[homedir]/manifest.txt"]} {
    set local_manifest [string trim [read_binary_file "[homedir]/manifest.txt"]]
    ulog "local manifest.txt: [string length $local_manifest] bytes"
}
if {[string length $local_manifest] == 0 && [file exists "[homedir]/manifest.tdb"]} {
    set local_manifest [string trim [read_binary_file "[homedir]/manifest.tdb"]]
    ulog "local manifest.tdb: [string length $local_manifest] bytes"
}
if {[string length $local_manifest] == 0} {
    ulog "no local manifest.txt/.tdb found (fine for 'all'/'only' mode; 'diff' mode will treat every file as changed)"
}
unset -nocomplain lmanifest
foreach {filename filesize filemtime filesha} $local_manifest {
    if {[file exists "[homedir]/$filename"] != 1} { set filesha 0 }
    set lmanifest($filename) $filesha
}

##############################################################################
# 5. decide which files to test
##############################################################################
unset -nocomplain tofetch
set order {}
foreach {filename filesize filemtime filesha} $remote_manifest {
    set take 0
    switch -- $::_ut_mode {
        all  { set take 1 }
        diff {
            if {![info exists lmanifest($filename)] || $lmanifest($filename) != $filesha} { set take 1 }
        }
        only {
            foreach pat $::_ut_only_patterns {
                if {[string match $pat $filename] || [string match $pat [file tail $filename]]} { set take 1 ; break }
            }
        }
    }
    if {$take} {
        set tofetch($filename) [list size $filesize mtime $filemtime sha $filesha]
        lappend order $filename
    }
}
set ntest [llength $order]
ulog_sep
ulog "will TEST-DOWNLOAD $ntest file(s) (mode=$::_ut_mode)"
if {$ntest == 0} {
    ulog "nothing to test -- in 'diff' mode this means the local tree already matches $progname."
    catch { close $::_ut_logchan }
    return
}

##############################################################################
# 6. dry-run download + verify loop
##############################################################################
set tmpdir "[data_directory]/update_test_tmp"
catch { file mkdir $tmpdir }

set n_ok 0
set n_bad 0
set n_httperr 0
set bad_files {}
set total_bytes 0
set start_ms [clock milliseconds]
set cnt 0

foreach k $order {
    incr cnt
    array set arr $tofetch($k)
    set expected_sha $arr(sha)
    set expected_size $arr(size)
    set url "$host/download/sync/$progname/[percent20encode $k]"
    set fn  "$tmpdir/dryrun_[expr {$cnt}]"

    array set F [ut_fetch $url $fn]
    set total_bytes [expr {$total_bytes + $F(bytes)}]
    set actual_sha [calc_sha $fn]

    set status "OK"
    if {$F(ok) != 1 || ($F(httpcode) ne "" && $F(httpcode) != 200)} {
        set status "HTTP-ERROR"
    } elseif {$actual_sha ne $expected_sha} {
        set status "SHA-MISMATCH"
    }

    if {$status eq "OK"} {
        incr n_ok
        # keep the noise down on big runs: only note every file at INFO-ish level
        if {$::_ut_mode ne "all" || ($cnt % 100 == 0)} {
            ulog "[format %5d $cnt]/$ntest OK   $k  (${F(bytes)} bytes, $F(transport), http $F(httpcode))"
        }
    } else {
        if {$status eq "HTTP-ERROR"} { incr n_httperr } else { incr n_bad }
        lappend bad_files $k
        ulog_sep
        ulog "[format %5d $cnt]/$ntest $status   $k"
        ulog "   url            : $url"
        ulog "   transport      : $F(transport)"
        ulog "   http status    : '$F(statusline)'  (code=$F(httpcode))"
        if {$F(err) ne ""} { ulog "   client error   : $F(err)" }
        ulog "   expected sha   : $expected_sha"
        ulog "   actual   sha   : $actual_sha"
        ulog "   expected size  : $expected_size (from manifest)"
        ulog "   downloaded     : $F(bytes) bytes on disk"
        ulog "   Content-Length : '$F(contentlength)'"
        ulog "   Content-Type   : '$F(contenttype)'"
        ulog "   Content-Encoding: '$F(contentencoding)'"
        ulog "   CDN X-Cache    : '$F(xcache)'    Age: '$F(age)'    CF-Cache-Status: '$F(cfcache)'"
        ulog "   ETag           : '$F(etag)'    Last-Modified: '$F(lastmod)'"
        ulog "   first bytes    : [_ut_head_bytes $fn 180]"

        if {$status eq "SHA-MISMATCH"} {
            # size heuristics
            if {$F(contentlength) ne "" && $F(contentlength) ne $expected_size} {
                ulog "   >> Content-Length ($F(contentlength)) != manifest size ($expected_size): the ORIGIN/EDGE is serving a DIFFERENT (stale) file than the manifest describes."
            }
            if {$F(bytes) ne "" && $F(contentlength) ne "" && $F(bytes) != $F(contentlength)} {
                ulog "   >> downloaded bytes ($F(bytes)) != Content-Length ($F(contentlength)): the transfer was TRUNCATED (flaky link / low-speed timeout)."
            }
            if {[string tolower $F(contentencoding)] eq "gzip" || [string tolower $F(contentencoding)] eq "br"} {
                ulog "   >> Content-Encoding=$F(contentencoding): the client stored COMPRESSED bytes (server compressed a .tcl and TclCurl did not auto-decode) -> sha can never match. Fix: send no Accept-Encoding, or add --compressed / -encoding \"\"."
            }
            # deterministic-vs-flaky probe: fetch a second time
            set fn2 "$tmpdir/dryrun_${cnt}_b"
            array set F2 [ut_fetch $url $fn2]
            set actual_sha2 [calc_sha $fn2]
            if {$actual_sha2 eq $actual_sha} {
                ulog "   >> 2nd fetch gave the SAME wrong sha ($actual_sha2, ${F2(bytes)} bytes): DETERMINISTIC. The server/CDN is consistently serving content that does not match the manifest -> STALE/CORRUPT CACHE (manifest.gz newer than the cached file, or vice-versa) or a build that wrote the manifest and the file inconsistently. NOT a flaky link."
            } else {
                ulog "   >> 2nd fetch gave a DIFFERENT sha ($actual_sha2, ${F2(bytes)} bytes): NON-DETERMINISTIC -> TRUNCATION / flaky network / low-speed-timeout, not a cache problem."
            }
            catch { file delete $fn2 }
            array unset F2
        }
        ulog_sep
    }

    catch { file delete $fn }
    array unset F
    array unset arr
}

##############################################################################
# 7. summary
##############################################################################
set elapsed [expr {([clock milliseconds] - $start_ms)/1000.0}]
ulog_sep
ulog "DRY-RUN COMPLETE (no local file was modified)"
ulog "  tested          : $ntest"
ulog "  ok              : $n_ok"
ulog "  sha mismatches  : $n_bad"
ulog "  http errors     : $n_httperr"
ulog "  bytes fetched   : $total_bytes"
ulog "  elapsed         : [format %.1f $elapsed] s"
if {[llength $bad_files] > 0} {
    ulog "  FAILED FILES    :"
    foreach b $bad_files { ulog "      - $b" }
    ulog ""
    ulog "  => The real updater would loop forever on the first of these (it retries 4x"
    ulog "     per file, then reschedules the whole update). See the per-file block above"
    ulog "     for whether it is a stale/corrupt CACHE (deterministic wrong sha) or a"
    ulog "     TRUNCATED download (non-deterministic / bytes != Content-Length)."
} else {
    ulog "  => All tested files downloaded and verified. The update would SUCCEED from"
    ulog "     THIS machine/network right now. If a specific tablet still fails, the"
    ulog "     problem is that tablet's CDN edge / link -- run this script ON that tablet."
}
catch { file delete -force $tmpdir }
catch { close $::_ut_logchan }
