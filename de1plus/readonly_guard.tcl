# readonly_guard.tcl -- catch (and neutralise) writes into the read-only bundle.
#
# Sourced by de1app.tcl right after the platform redirect (ios/osx/google_play),
# before pkgIndex.tcl / any package load. A hard NO-OP unless BOTH hold:
#   * ::_readonly_bundle is set (a packaged build that copied itself to a writable
#     ~/Documents/Decent and cd'd there -- so the ORIGINAL bundle is now read-only),
#   * a `writeguard.flag` marker exists in that bundle (dropped by the packaging
#     scripts for the diagnostic TEST builds only).
#
# WHY: the whole packaged-app design is "copy the tree to Documents and run from
# there, so nothing writes into the signed/sealed bundle." A notarized .app whose
# bundle is mutated is reported "damaged"; a sealed APK that mutates itself breaks
# its integrity ("encryption seal"); an iOS bundle is simply read-only. The
# copy-everything redirect makes cwd + [homedir] the writable copy, so ALL cwd- and
# [homedir]-relative writes are already safe. This guard exists to catch the
# STRAGGLERS: code (often an extension) that captured an ABSOLUTE bundle path early,
# or writes next to its own script via [info script]. It wraps the Tcl write
# primitives, and for any target that resolves inside the frozen bundle it:
#   1. logs the offending call + a stack trace to <writable>/readonly_violations.log
#      (so we get a canonical list of every remaining in-bundle writer), and
#   2. transparently REDIRECTS the write to the matching path under the writable
#      copy -- so the app keeps working AND we still learn where the writes are.
#
# Flip ::_rog_reject to 1 to make an in-bundle write a hard error instead (John's
# "tickle error pops up" mode) once the offenders are all fixed.

namespace eval ::rog {}

set ::_rog_active 0
if {[info exists ::_readonly_bundle] \
        && [file exists [file join $::_readonly_bundle "writeguard.flag"]]} {
    set ::_rog_active 1
}

if {$::_rog_active} {

    set ::_rog_bundle  [file normalize $::_readonly_bundle]
    # The writable copy we redirect into. $::home is the copy at this point.
    set ::_rog_writable [expr {[info exists ::home] ? [file normalize $::home] \
                                                    : [pwd]}]
    set ::_rog_logfile [file join $::_rog_writable "readonly_violations.log"]
    set ::_rog_reject 0   ;# 0 = log+redirect (keep working); 1 = hard error

    # Is $path inside the frozen read-only bundle (and NOT inside the writable copy,
    # which can sit under it on some layouts)? $path must already be normalized.
    proc ::rog::in_bundle {path} {
        if {$path eq $::_rog_bundle} { return 1 }
        if {[string match "$::_rog_writable" $path] \
                || [string match "$::_rog_writable/*" $path]} { return 0 }
        return [expr {[string match "$::_rog_bundle/*" $path]}]
    }

    # Map a bundle path to the matching path under the writable copy.
    proc ::rog::redirect {path} {
        if {$path eq $::_rog_bundle} { return $::_rog_writable }
        set tail [string range $path [expr {[string length $::_rog_bundle] + 1}] end]
        return [file join $::_rog_writable $tail]
    }

    proc ::rog::log {what path} {
        catch {
            set fh [::rog::real_open $::_rog_logfile a]
            set ts [clock format [clock seconds] -format "%Y-%m-%d %H:%M:%S"]
            puts $fh "\[$ts\] $what -> $path"
            # A short stack trace pins the exact caller, so each offender is
            # fixable at its source.
            for {set i [expr {[info level] - 1}]} {$i > 0} {incr i -1} {
                catch { puts $fh "      #$i [info level $i]" }
            }
            close $fh
        }
    }

    # Given a target path (possibly relative / un-normalized), if it lands in the
    # bundle: log it, and return the redirected writable path; else return as-is.
    proc ::rog::maybe {what target} {
        set norm [file normalize $target]
        if {[::rog::in_bundle $norm]} {
            ::rog::log $what $norm
            if {$::_rog_reject} {
                return -code error "readonly_guard: write into read-only bundle refused: $norm"
            }
            set redir [::rog::redirect $norm]
            catch { file mkdir [file dirname $redir] }
            return $redir
        }
        return $target
    }

    # --- wrap `open` (the main text-write path: log.txt, updater logs, profiles) --
    rename ::open ::rog::real_open
    proc ::open {args} {
        set fname [lindex $args 0]
        # Pipelines ("|cmd ...") are not file paths -- pass through untouched.
        if {[string index $fname 0] ne "|"} {
            set mode [expr {[llength $args] > 1 ? [lindex $args 1] : "r"}]
            # write-ish access: w / a / +, or a POSIX access list with a writer.
            set writes 0
            if {[string match {*[wa+]*} $mode]} { set writes 1 }
            foreach _m {WRONLY RDWR APPEND CREAT TRUNC} {
                if {[lsearch -exact $mode $_m] >= 0} { set writes 1 }
            }
            if {$writes} {
                catch { set fname [::rog::maybe "open $mode" $fname] }
                set args [lreplace $args 0 0 $fname]
            }
        }
        return [::rog::real_open {*}$args]
    }

    # --- wrap `file` (copy/rename/mkdir/delete into the bundle) -----------------
    rename ::file ::rog::real_file
    proc ::file {sub args} {
        # Everything is wrapped in catch-fallback: if our option parsing is ever
        # wrong, defer to the real `file` so we never break a valid call.
        if {[catch {::rog::file_dispatch $sub $args} out]} {
            return [::rog::real_file $sub {*}$args]
        }
        return $out
    }
    proc ::rog::file_dispatch {sub argv} {
        switch -exact -- $sub {
            copy - rename {
                # file copy|rename ?-force? ?--? source ?source ...? target
                set opts {}
                set rest $argv
                while {[llength $rest]} {
                    set a [lindex $rest 0]
                    if {$a eq "-force" || $a eq "--"} {
                        lappend opts $a; set rest [lrange $rest 1 end]
                        if {$a eq "--"} break
                    } else break
                }
                if {[llength $rest] < 2} { error "passthrough" }
                set target [lindex $rest end]
                set sources [lrange $rest 0 end-1]
                set target [::rog::maybe "file $sub" $target]
                return [::rog::real_file $sub {*}$opts {*}$sources $target]
            }
            mkdir {
                set out {}
                foreach d $argv { lappend out [::rog::maybe "file mkdir" $d] }
                return [::rog::real_file mkdir {*}$out]
            }
            delete {
                # file delete ?-force? ?--? pathname ...  -- an in-bundle delete
                # can't touch the read-only bundle anyway; log it and drop that path.
                set opts {}
                set rest $argv
                while {[llength $rest]} {
                    set a [lindex $rest 0]
                    if {$a eq "-force" || $a eq "--"} {
                        lappend opts $a; set rest [lrange $rest 1 end]
                        if {$a eq "--"} break
                    } else break
                }
                set keep {}
                foreach p $rest {
                    set norm [file normalize $p]
                    if {[::rog::in_bundle $norm]} {
                        ::rog::log "file delete" $norm
                        if {$::_rog_reject} { error "readonly_guard: delete in bundle refused: $norm" }
                    } else { lappend keep $p }
                }
                if {![llength $keep]} { return {} }
                return [::rog::real_file delete {*}$opts {*}$keep]
            }
            default {
                error "passthrough"
            }
        }
    }

    catch { ::rog::log "readonly_guard active" $::_rog_bundle }
}
