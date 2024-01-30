package require de1_bluetooth 1.1

set plugin_name "decentscale_off"


namespace eval ::plugins::${plugin_name} {
    variable author "Martin D"
    variable contact "Via Diaspora"
    variable version 1.0
    variable name "Decent Scale Off"
    variable description "Turn battery-powered Decent Scale off when DE1 sleeps"

    proc decentscale_disable_lcd {} {
        if {$::de1(scale_device_handle) == 0 || $::settings(scale_type) != "decentscale"} {
                return
        }
        set screenoff [decent_scale_make_command 0A 00 00]

        if {[ifexists ::sinstance($::de1(suuid_decentscale))] == ""} {
                ::bt::msg -DEBUG "decentscale not connected, cannot disable LCD"
                return
        }

        userdata_append "SCALE: decentscale : disable LCD" [list ble write $::de1(scale_device_handle) $::de1(suuid_decentscale) $::sinstance($::de1(suuid_decentscale)) $::de1(cuuid_decentscale_write) $::cinstance($::de1(cuuid_decentscale_write)) $screenoff] 0
    }

    proc main {} {
        proc ::scale_disable_lcd {} {
            msg "Scale Sleep for Power from Battery"

            ::bt::msg -NOTICE scale_sleep
            if {$::settings(scale_type) == "decentscale"} {
                if {$::de1(scale_usb_powered) == 0} {
                    after 3000 decentscale_sleep
                } else {
#                    decentscale_disable_lcd
                    ::plugins::scale_off::decentscale_disable_lcd
                }
            }
        }
    }
}


