# safe_write.tcl — Atomic file write with backup retention
#
# Provides write_file and fast_write_open. No package requires, no side effects
# at source time. Dependencies (msg) must be defined before calling write_file.
#
# Sourced by updater.tcl. Also sourced directly by tests.

proc fast_write_open {fn parms} {
    set success 0
    set f 0
    set errcode [catch {
        set f [open $fn $parms]

        # Michael argues that there's no need to go nonblocking if you have a write buffer defined.
        # https://3.basecamp.com/3671212/buckets/7351439/messages/3033510129#__recording_3037579684
        # so disabling for now, to see if he's right.
        # fconfigure $f -blocking 0

        # explicitly declare LF as the line feed character, as that's what it is on unix/android/macos - only windows doesn't and it causes issues
        fconfigure $f -buffersize 1000000 -translation {lf lf}
        set success 1
    }]

    if {$errcode != 0} {
        catch {
            msg -ERROR "fast_write_open $::errorInfo"
        }
    }

    return $f
    #return ""
}

proc write_file {filename data} {
    set success 0
    set tmpfile "${filename}.tmp"
    set bakfile "${filename}.bak"

    set errcode [catch {
        # 1. Write to temp file
        set fn [fast_write_open $tmpfile w]
        puts $fn $data
        close $fn

        # 2. Copy current file to .bak (original stays in place)
        if {[file exists $filename]} {
            file copy -force $filename $bakfile
        }

        # 3. Rename .tmp over target (atomic on POSIX/Android)
        file rename -force $tmpfile $filename

        set success 1
    }]

    if {$errcode != 0} {
        catch { msg -ERROR "write_file '$filename' $::errorInfo" }
        # Clean up failed temp file if it exists
        catch { file delete $tmpfile }
    }

    return $success
}
