# safe_load.tcl — Settings corruption detection and backup recovery
#
# Provides load_settings_recover. No package requires, no side effects at source time.
# Dependencies (read_binary_file, msg, popup) must be defined before calling.
#
# Sourced by utils.tcl. Also sourced directly by tests.

# load_settings_recover — Detect corruption in a settings file and recover from .bak
#
# Arguments:
#   fn       - path to the settings file
#   contents - the already-read contents of the settings file (UTF-8 decoded)
#
# Side effects:
#   - On successful load or recovery: populates ::settings array
#   - On recovery: calls popup with notification, logs via msg
#   - On total failure: leaves ::settings empty, logs error
#
# Returns a dict:
#   corrupted  - 1 if corruption was detected, 0 otherwise
#   recovered  - 1 if successfully recovered from .bak, 0 otherwise
#   contents   - the effective settings_file_contents (may be "" if recovery failed)

proc load_settings_recover {fn contents} {
    set corrupted 0
    set recovered 0
    set settings_file_contents $contents

    if {[file exists $fn] && [string length $settings_file_contents] == 0} {
        # File exists but is empty — power loss during write
        set corrupted 1
        msg -WARNING "Settings file exists but is empty — likely power loss during write"
    } elseif {[string length $settings_file_contents] > 0} {
        if {[catch {array set ::settings $settings_file_contents} err]} {
            # File exists but content is malformed
            set corrupted 1
            msg -WARNING "Settings file is corrupted: $err"
        }
    }
    # Note: if file doesn't exist, settings_file_contents is "" and corrupted stays 0
    # — falls through to existing fresh-defaults behavior

    if {$corrupted} {
        set bakfile "${fn}.bak"
        if {[file exists $bakfile]} {
            set bak_contents [encoding convertfrom utf-8 [read_binary_file $bakfile]]
            if {[string length $bak_contents] > 0 && ![catch {array set ::settings $bak_contents}]} {
                msg -WARNING "Settings recovered from backup file"
                catch { popup "Settings recovered from backup" }
                set recovered 1
            } else {
                msg -ERROR "Settings backup is also corrupted — using fresh defaults"
                set settings_file_contents ""
            }
        } else {
            msg -WARNING "Settings corrupted and no backup exists — using fresh defaults"
            set settings_file_contents ""
        }
    }

    return [list corrupted $corrupted recovered $recovered contents $settings_file_contents]
}
