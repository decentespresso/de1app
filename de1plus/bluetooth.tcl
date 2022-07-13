package provide de1_bluetooth 1.1

package require de1_comms
package require de1_device_scale 1.0
package require de1_logging 1.2

namespace eval ::bt {

	proc ::bt::msg {first args} {

		::logging::default_logger $first "bluetooth:" {*}$args
	}
}

## Scales
### Generics

proc scale_enable_lcd {} {
	::bt::msg -NOTICE scale_enable_lcd
	if {$::settings(scale_type) == "atomaxskale"} {
		skale_enable_lcd
	} elseif {$::settings(scale_type) == "decentscale"} {
		decentscale_enable_lcd
		# double-sending command, half a second later, because sometimes the decent scale command buffer has not finished the previous command and drops the next one
		after 1000 decentscale_enable_lcd
	}
}

proc scale_disable_lcd {} {
	::bt::msg -NOTICE scale_disable_lcd
	if {$::settings(scale_type) == "atomaxskale"} {
		set do_this 1
		if {$do_this == 1} {
			skale_disable_lcd
		}
	} elseif {$::settings(scale_type) == "decentscale"} {
		
		set do_this 1
		if {$do_this == 1} {
			# disabled the LCD off for Decent Scale, so that we don't give false impression tha the scale is off
			# ideally in future firmware we can find out if they are on usb power, and disable LEDs if they are
			decentscale_disable_lcd
			# double-sending command, half a second later, because sometimes the decent scale command buffer has not finished the previous command and drops the next one
			after 500 decentscale_disable_lcd
		}
	}
}

proc scale_timer_start {} {
	::bt::msg -NOTICE scale_timer_start

	if {$::settings(scale_type) == "atomaxskale"} {
		skale_timer_start
	} elseif {$::settings(scale_type) == "decentscale"} {
		decentscale_timer_start
		# double-sending command, half a second later, because sometimes the decent scale command buffer has not finished the previous command and drops the next one
		after 500 decentscale_timer_start
	} elseif {$::settings(scale_type) == "felicita"} {
		felicita_start_timer
	} elseif {$::settings(scale_type) == "eureka_precisa"} {
		eureka_precisa_start_timer
	}
}

proc scale_timer_stop {} {
	::bt::msg -NOTICE scale_timer_stop

	if {$::settings(scale_type) == "atomaxskale"} {
		skale_timer_stop
	} elseif {$::settings(scale_type) == "decentscale"} {
		decentscale_timer_stop
		# double-sending command, half a second later, because sometimes the decent scale command buffer has not finished the previous command and drops the next one
		after 500 decentscale_timer_stop
	} elseif {$::settings(scale_type) == "felicita"} {
		felicita_stop_timer
	} elseif {$::settings(scale_type) == "eureka_precisa"} {
		eureka_precisa_stop_timer
	}
}


# timer off is badly named, it actually is "timer set to zero"
proc scale_timer_reset {} {
	::bt::msg -NOTICE scale_timer_reset

	if {$::settings(scale_type) == "atomaxskale"} {
		skale_timer_reset
	} elseif {$::settings(scale_type) == "decentscale"} {
		decentscale_timer_reset
		# double-sending command, half a second later, because sometimes the decent scale command buffer has not finished the previous command and drops the next one
		after 500 decentscale_timer_reset
	} elseif {$::settings(scale_type) == "felicita"} {
		felicita_timer_reset
	} elseif {$::settings(scale_type) == "eureka_precisa"} {
		eureka_precisa_reset_timer
	}
}

proc scale_tare {} {
	::bt::msg -NOTICE scale_tare

	::bt::msg -WARNING "DEPRECATED: scale_tare is deprecated in favor of ::device::scale::tare"
	::device::scale::tare
}

proc scale_enable_weight_notifications {} {

	if {$::settings(scale_type) == "atomaxskale"} {
		skale_enable_weight_notifications
	} elseif {$::settings(scale_type) == "decentscale"} {
		decentscale_enable_notifications
	} elseif {$::settings(scale_type) == "acaiascale"} {
		acaia_enable_weight_notifications $::de1(suuid_acaia_ips) $::de1(cuuid_acaia_ips_age)
	} elseif {$::settings(scale_type) == "acaiapyxis"} {
		#acaia_enable_weight_notifications $::de1(suuid_acaia_pyxis) $::de1(cuuid_acaia_pyxis_status)
	} elseif {$::settings(scale_type) == "felicita"} {
		felicita_enable_weight_notifications
	} elseif {$::settings(scale_type) == "hiroiajimmy"} {
		hiroia_enable_weight_notifications
	}  elseif {$::settings(scale_type) == "eureka_precisa"} {
		eureka_precisa_enable_weight_notifications
	}
}

proc scale_enable_button_notifications {} {
	::bt::msg -NOTICE scale_enable_button_notifications

	if {$::settings(scale_type) == "atomaxskale"} {
		skale_enable_button_notifications
	} elseif {$::settings(scale_type) == "decentscale"} {
		# nothing
	}
}

proc scale_enable_grams {} {
	::bt::msg -NOTICE scale_enable_grams

	if {$::settings(scale_type) == "atomaxskale"} {
		skale_enable_grams
	} elseif {$::settings(scale_type) == "decentscale"} {
		# nothing to do, as this is already set as part of LED on command
	} elseif {$::settings(scale_type) == "eureka_precisa"} {
		eureka_precisa_set_unit
	}
}


#### Atomax Skale
proc skale_timer_start {} {
	if {$::de1(scale_device_handle) == 0 || $::settings(scale_type) != "atomaxskale"} {
		return
	}

	if {[ifexists ::sinstance($::de1(suuid_skale))] == ""} {
		::bt::msg -DEBUG "Skale not connected, cannot start timer"
		return
	}

	set timeron [binary decode hex "DD"]
	userdata_append "SCALE: Skale : timer start" [list ble write $::de1(scale_device_handle) $::de1(suuid_skale) $::sinstance($::de1(suuid_skale)) $::de1(cuuid_skale_EF80) $::cinstance($::de1(cuuid_skale_EF80)) $timeron] 0

}

proc skale_enable_button_notifications {} {
	if {$::de1(scale_device_handle) == 0 || $::settings(scale_type) != "atomaxskale"} {
		return
	}

	if {[ifexists ::sinstance($::de1(suuid_skale))] == ""} {
		::bt::msg -DEBUG "Skale not connected, cannot enable button notifications"
		return
	}


	userdata_append "SCALE: enable Skale button notifications" [list ble enable $::de1(scale_device_handle) $::de1(suuid_skale) $::sinstance($::de1(suuid_skale)) $::de1(cuuid_skale_EF82) $::cinstance($::de1(cuuid_skale_EF82))] 1
}


proc skale_enable_grams {} {
	if {$::de1(scale_device_handle) == 0 || $::settings(scale_type) != "atomaxskale"} {
		return
	}
	set grams [binary decode hex "03"]

	if {[ifexists ::sinstance($::de1(suuid_skale))] == ""} {
		::bt::msg -DEBUG "Skale not connected, cannot enable grams"
		return
	}

	userdata_append "SCALE: Skale : enable grams" [list ble write $::de1(scale_device_handle) $::de1(suuid_skale) $::sinstance($::de1(suuid_skale)) $::de1(cuuid_skale_EF80) $::cinstance($::de1(cuuid_skale_EF80)) $grams] 1
}

proc skale_enable_lcd {} {
	if {$::de1(scale_device_handle) == 0 || $::settings(scale_type) != "atomaxskale"} {
		return
	}
	set screenon [binary decode hex "ED"]
	set displayweight [binary decode hex "EC"]

	if {[ifexists ::sinstance($::de1(suuid_skale))] == ""} {
		::bt::msg -DEBUG "Skale not connected, cannot enable LCD"
		return
	}

	userdata_append "SCALE: Skale : enable LCD" [list ble write $::de1(scale_device_handle) $::de1(suuid_skale) $::sinstance($::de1(suuid_skale)) $::de1(cuuid_skale_EF80) $::cinstance($::de1(cuuid_skale_EF80)) $screenon] 0
	userdata_append "SCALE: Skale : display weight on LCD" [list ble write $::de1(scale_device_handle) $::de1(suuid_skale) $::sinstance($::de1(suuid_skale)) $::de1(cuuid_skale_EF80) $::cinstance($::de1(cuuid_skale_EF80)) $displayweight] 0

}

proc skale_disable_lcd {} {
	if {$::de1(scale_device_handle) == 0 || $::settings(scale_type) != "atomaxskale"} {
		return
	}
	set screenoff [binary decode hex "EE"]

	if {[ifexists ::sinstance($::de1(suuid_skale))] == ""} {
		::bt::msg -DEBUG "Skale not connected, cannot disable LCD"
		return
	}

	userdata_append "SCALE: Skale : disable LCD" [list ble write $::de1(scale_device_handle) $::de1(suuid_skale) $::sinstance($::de1(suuid_skale)) $::de1(cuuid_skale_EF80) $::cinstance($::de1(cuuid_skale_EF80)) $screenoff] 0
}

proc skale_timer_stop {} {

	if {$::de1(scale_device_handle) == 0 || $::settings(scale_type) != "atomaxskale"} {
		return
	}
	set tare [binary decode hex "D1"]

	if {[ifexists ::sinstance($::de1(suuid_skale))] == ""} {
		::bt::msg -DEBUG "Skale not connected, cannot stop timer"
		return
	}

	userdata_append "SCALE: Skale: timer stop" [list ble write $::de1(scale_device_handle) $::de1(suuid_skale) $::sinstance($::de1(suuid_skale)) $::de1(cuuid_skale_EF80) $::cinstance($::de1(cuuid_skale_EF80)) $tare] 0
}

proc skale_timer_reset {} {

	if {$::de1(scale_device_handle) == 0 || $::settings(scale_type) != "atomaxskale"} {
		return
	}
	set tare [binary decode hex "D0"]

	if {[ifexists ::sinstance($::de1(suuid_skale))] == ""} {
		::bt::msg -DEBUG "Skale not connected, cannot reset timer"
		return
	}

	userdata_append "SCALE: Skale: timer reset" [list ble write $::de1(scale_device_handle) $::de1(suuid_skale) $::sinstance($::de1(suuid_skale)) $::de1(cuuid_skale_EF80) $::cinstance($::de1(cuuid_skale_EF80)) $tare] 0
}

proc skale_tare {} {
	if {$::de1(scale_device_handle) == 0 || $::settings(scale_type) != "atomaxskale"} {
		return
	}
	set tare [binary decode hex "10"]

	# if this was a scheduled tare, indicate that the tare has completed
	unset -nocomplain ::scheduled_scale_tare_id

	#set ::de1(final_espresso_weight) 0

	if {[ifexists ::sinstance($::de1(suuid_skale))] == ""} {
		::bt::msg -DEBUG "Skale not connected, cannot tare"
		return
	}

	userdata_append "SCALE: Skale: tare" [list ble write $::de1(scale_device_handle) $::de1(suuid_skale) $::sinstance($::de1(suuid_skale)) $::de1(cuuid_skale_EF80) $::cinstance($::de1(cuuid_skale_EF80)) $tare] 0
}

proc skale_enable_weight_notifications {} {
	if {$::de1(scale_device_handle) == 0 || $::settings(scale_type) != "atomaxskale"} {
		return
	}

	if {[ifexists ::sinstance($::de1(suuid_skale))] == ""} {
		::bt::msg -DEBUG "Skale not connected, cannot enable weight notifications"
		return
	}

	userdata_append "SCALE: enable Skale weight notifications" [list ble enable $::de1(scale_device_handle) $::de1(suuid_skale) $::sinstance($::de1(suuid_skale)) $::de1(cuuid_skale_EF81) $::cinstance($::de1(cuuid_skale_EF81))] 1
}


#### Felicita
proc felicita_enable_weight_notifications {} {
	if {$::de1(scale_device_handle) == 0 || $::settings(scale_type) != "felicita"} {
		return
	}

	if {[ifexists ::sinstance($::de1(suuid_felicita))] == ""} {
		error "Felicita Scale not connected, cannot enable weight notifications"
		return
	}

	userdata_append "SCALE: enable felicita scale weight notifications" [list ble enable $::de1(scale_device_handle) $::de1(suuid_felicita) $::sinstance($::de1(suuid_felicita)) $::de1(cuuid_felicita) $::cinstance($::de1(cuuid_felicita))] 1
}

proc felicita_tare {} {

	if {$::de1(scale_device_handle) == 0 || $::settings(scale_type) != "felicita"} {
		return
	}

	if {[ifexists ::sinstance($::de1(suuid_felicita))] == ""} {
		error "Felicita Scale not connected, cannot send tare cmd"
		return
	}

	set tare [binary decode hex "54"]

	userdata_append "SCALE: felicita tare" [list ble write $::de1(scale_device_handle) $::de1(suuid_felicita) $::sinstance($::de1(suuid_felicita)) $::de1(cuuid_felicita) $::cinstance($::de1(cuuid_felicita)) $tare] 0
	# The tare is not yet confirmed to us, we can therefore assume it worked out
}

proc felicita_timer_reset {} {

	if {$::de1(scale_device_handle) == 0 || $::settings(scale_type) != "felicita"} {
		return
	}

	if {[ifexists ::sinstance($::de1(suuid_felicita))] == ""} {
		error "Felicita Scale not connected, cannot send timer cmd"
		return
	}

	set tare [binary decode hex "43"]

	userdata_append "SCALE: felicita timer reset" [list ble write $::de1(scale_device_handle) $::de1(suuid_felicita) $::sinstance($::de1(suuid_felicita)) $::de1(cuuid_felicita) $::cinstance($::de1(cuuid_felicita)) $tare] 0
}
proc felicita_start_timer {} {

	if {$::de1(scale_device_handle) == 0 || $::settings(scale_type) != "felicita"} {
		return
	}

	if {[ifexists ::sinstance($::de1(suuid_felicita))] == ""} {
		error "Felicita Scale not connected, cannot send timer cmd"
		return
	}

	set tare [binary decode hex "52"]

	userdata_append "SCALE: felicita timer start" [list ble write $::de1(scale_device_handle) $::de1(suuid_felicita) $::sinstance($::de1(suuid_felicita)) $::de1(cuuid_felicita) $::cinstance($::de1(cuuid_felicita)) $tare] 0
}
proc felicita_stop_timer {} {

	if {$::de1(scale_device_handle) == 0 || $::settings(scale_type) != "felicita"} {
		return
	}

	if {[ifexists ::sinstance($::de1(suuid_felicita))] == ""} {
		error "Felicita Scale not connected, cannot send timer cmd"
		return
	}

	set tare [binary decode hex "53"]

	userdata_append "SCALE: felicita timer stop" [list ble write $::de1(scale_device_handle) $::de1(suuid_felicita) $::sinstance($::de1(suuid_felicita)) $::de1(cuuid_felicita) $::cinstance($::de1(cuuid_felicita)) $tare] 0
}

proc felicita_parse_response { value } {
	if {[string bytelength $value] >= 9} {
		binary scan $value cucua1a6 h1 h2 sign weight
		if {[info exists weight] && $h1 == 1 && $h2 == 2 } {
			set weight [ scan $weight %d ]
			if {$weight == ""} { return }
			if {$sign == "-"} {
				set weight [expr $weight * -1]
			}
			::device::scale::process_weight_update [expr $weight / 100.0] ;# $event_time
		}
	}
}


#### Hiroia Jimmy
proc hiroia_enable_weight_notifications {} {
	if {$::de1(scale_device_handle) == 0 || $::settings(scale_type) != "hiroiajimmy"} {
		return
	}

	if {[ifexists ::sinstance($::de1(suuid_hiroiajimmy))] == ""} {
		error "Hiroia Jimmy Scale not connected, cannot enable weight notifications"
		return
	}

	userdata_append "SCALE: enable hiroiajimmy scale weight notifications" [list ble enable $::de1(scale_device_handle) $::de1(suuid_hiroiajimmy) $::sinstance($::de1(suuid_hiroiajimmy)) $::de1(cuuid_hiroiajimmy_status) $::cinstance($::de1(cuuid_hiroiajimmy_status))] 1
}

proc hiroia_tare {} {

	if {$::de1(scale_device_handle) == 0 || $::settings(scale_type) != "hiroiajimmy"} {
		return
	}

	if {[ifexists ::sinstance($::de1(suuid_hiroiajimmy))] == ""} {
		error "Hiroia Jimmy Scale not connected, cannot send tare cmd"
		return
	}

	set tare [binary decode hex "0700"]

	userdata_append "SCALE: hiroiajimmy tare" [list ble write $::de1(scale_device_handle) $::de1(suuid_hiroiajimmy) $::sinstance($::de1(suuid_hiroiajimmy)) $::de1(cuuid_hiroiajimmy_cmd) $::cinstance($::de1(cuuid_hiroiajimmy_cmd)) $tare] 0
	# The tare is not yet confirmed to us, we can therefore assume it worked out
}

proc hiroia_parse_response { value } {
	if {[string bytelength $value] >= 7} {
		append value [binary decode hex 00]
		binary scan $value cucucucui h1 h2 h3 h4 weight

		if {[info exists weight]} {
			if {$weight >= 8388608} {
				set weight [expr (0xFFFFFF - $weight) * -1]
			}
			::device::scale::process_weight_update [expr $weight / 10.0] ;# $event_time
		} else {
			error "weight non exist"
		}
	}
}

#### Eureka Precisa / Krell CFS-9002
proc eureka_precisa_enable_weight_notifications {} {
	if {$::de1(scale_device_handle) == 0 || $::settings(scale_type) != "eureka_precisa"} {
		return
	}

	if {[ifexists ::sinstance($::de1(suuid_eureka_precisa))] == ""} {
		error "Eureka Precisa Scale not connected, cannot enable weight notifications"
		return
	}

	userdata_append "SCALE: enable eureka precisa scale weight notifications" [list ble enable $::de1(scale_device_handle) $::de1(suuid_eureka_precisa) $::sinstance($::de1(suuid_eureka_precisa)) $::de1(cuuid_eureka_precisa_status) $::cinstance($::de1(cuuid_eureka_precisa_status))] 1
}

proc eureka_precisa_cmd {payload name} {

	if {$::de1(scale_device_handle) == 0 || $::settings(scale_type) != "eureka_precisa"} {
		return
	}

	if {[ifexists ::sinstance($::de1(suuid_eureka_precisa))] == ""} {
		error "Eureka Precisa Scale not connected, cannot send $name cmd"
		return
	}

	userdata_append "SCALE: eureka_precisa $name" [list ble write $::de1(scale_device_handle) $::de1(suuid_eureka_precisa) $::sinstance($::de1(suuid_eureka_precisa)) $::de1(cuuid_eureka_precisa_cmd) $::cinstance($::de1(cuuid_eureka_precisa_cmd)) $payload] 0
	# The tare is not yet confirmed to us, we can therefore assume it worked out
}

proc eureka_precisa_tare {} {

	set tare [binary decode hex "AA023131"]

	eureka_precisa_cmd $tare "tare"

}

proc eureka_precisa_turn_off {} {

	set payload [binary decode hex "AA023232"]

	eureka_precisa_cmd $payload "turn scale off"
}

proc eureka_precisa_start_timer {} {
	set payload [binary decode hex "AA023333"]

	eureka_precisa_cmd $payload "start timer"
}

proc eureka_precisa_stop_timer {} {
	set payload [binary decode hex "AA023434"]

	eureka_precisa_cmd $payload "stop timer"
}

proc eureka_precisa_reset_timer {} {
	# also stops
	set payload [binary decode hex "AA023535"]

	eureka_precisa_cmd $payload "reset timer"
}

proc eureka_precisa_beep_twice {} {
	set payload [binary decode hex "AA023737"]

	eureka_precisa_cmd $payload "beep twice"
}

proc eureka_precisa_set_unit {} {
	# also stops
	set grams [binary decode hex "AA033600"]
	set oz [binary decode hex "AA033601"]
	set ml [binary decode hex "AA033602"]

	eureka_precisa_cmd $grams "set unit"
}

proc eureka_precisa_parse_response { value } {
	if {[string bytelength $value] >= 9} {
		binary scan $value "cucucu cu su cu su" h1 h2 h3 timer_running timer sign weight
		# AA (<- header) 09 (<- type) 14 (<-notification type)
		if {[info exists weight] && $h1 == 170 && $h2 == 9 && $h3 == 65 } {
			if {$sign == 1} {
				set weight [expr $weight * -1]
			}
			::device::scale::process_weight_update [expr $weight / 10.0] ;# $event_time
		}
	}
}



#### Acaia
set ::acaia_command_buffer ""

proc acaia_encode {msgType payload} {

	set HEADER1 [binary decode hex "EF"];
	set HEADER2 [binary decode hex "DD"];
	set TYPE [binary decode hex $msgType];

	# TODO calculate checksum instead of hardcofig it
	set data "$HEADER1${HEADER2}${TYPE}[binary decode hex $payload]"
	return $data
}

proc acaia_tare {suuid cuuid} {

	if {[ifexists ::sinstance($suuid)] == "" || $::de1(scale_device_handle) == 0} {
		::bt::msg -DEBUG "Acaia Scale not connected, cannot send tare cmd"
		return
	}

	set sinstance $::sinstance($suuid)
	set cinstance $::cinstance($cuuid)

	set tare [acaia_encode 04  0000000000000000000000000000000000]

	userdata_append "SCALE: send acaia tare" [list ble write $::de1(scale_device_handle) $suuid $sinstance $cuuid $cinstance $tare] 1

	# The tare is not yet confirmed to us, we can therefore assume it worked out
}

proc acaia_send_heartbeat {suuid cuuid} {

	if {[ifexists ::sinstance($suuid)] == "" || $::de1(scale_device_handle) == 0} {
		::bt::msg -DEBUG "Acaia Scale not connected ($suuid), cannot send app heartbeat"
		return
	}
	set heartbeat [acaia_encode 00 02000200]

	set sinstance $::sinstance($suuid)
	set cinstance $::cinstance($cuuid)

	userdata_append "SCALE: send acaia heartbeat" [list ble write $::de1(scale_device_handle) $suuid $sinstance $cuuid $cinstance $heartbeat] 1

	if { $::settings(force_acaia_heartbeat) == 1 } {
		after 1000 [list acaia_send_config $suuid $cuuid]
		after 2000 [list acaia_send_heartbeat $suuid $cuuid]
	}
}

proc acaia_send_ident {suuid cuuid} {

	if {[ifexists ::sinstance($suuid)] == "" || $::de1(scale_device_handle) == 0} {
		::bt::msg -DEBUG "Acaia Scale not connected, cannot send app ident"
		return
	}

	set ident [acaia_encode 0B 3031323334353637383930313233349A6D]
	set sinstance $::sinstance($suuid)
	set cinstance $::cinstance($cuuid)

	userdata_append "SCALE: send acaia ident" [list ble write $::de1(scale_device_handle) $suuid $sinstance $cuuid $cinstance $ident] 1
}

proc acaia_send_config {suuid cuuid} {

	if {[ifexists ::sinstance($suuid)] == "" || $::de1(scale_device_handle) == 0} {
		::bt::msg -DEBUG "Acaia Scale not connected, cannot send app config"
		return
	}

	set ident [acaia_encode 0C 0900010102020103041106]

	set sinstance $::sinstance($suuid)
	set cinstance $::cinstance($cuuid)

	userdata_append "SCALE: send acaia config" [list ble write $::de1(scale_device_handle) $suuid $sinstance $cuuid $cinstance $ident] 1
}


proc acaia_enable_weight_notifications {suuid cuuid} {

	if {[ifexists ::sinstance($suuid)] == "" || $::de1(scale_device_handle) == 0} {
		::bt::msg -DEBUG "Acaia Scale not connected, cannot enable weight notifications"
		return
	}

	set sinstance $::sinstance($suuid)
	set cinstance $::cinstance($cuuid)

	userdata_append "SCALE: enable acaia scale weight notifications" [list ble enable $::de1(scale_device_handle) $suuid $sinstance $cuuid $cinstance] 1
}

proc acaia_parse_response { value } {

	append ::acaia_command_buffer $value

	if {[string bytelength $::acaia_command_buffer] > 4} {
		# 0xEF
		set HEADER1 239
		# 0xDD
		set HEADER2 221

		binary scan $::acaia_command_buffer cucucucucuicucu \
			h1 h2 msgtype len event_type weight unit neg
		if { [info exists h1] && [info exists h2] && [info exists len]} {
			if { ($h1 == $HEADER1) && ($h2 == $HEADER2) \
				&& [info exists neg] \
				&& $msgtype == 12 && $event_type == 5 } {
				# we have valid data, extract it
				set calulated_weight [expr {$weight / pow(10.0, $unit)}]
				set is_negative [expr {$neg > 1.0}]
				if {$is_negative} {
					set calulated_weight [expr {$calulated_weight * -1.0}]
				}
				set sensorweight $calulated_weight
				::device::scale::process_weight_update $sensorweight ;# $event_time
			}
			if { [string bytelength $::acaia_command_buffer] >= $len } {
				set ::acaia_command_buffer ""
			}
		}
	}
}

#### Decent Scale


# cmdtype is either 0x0A for LED (cmddata 00=off, 01=on), or 0x0F for tare (cmdata = incremented char counter for each TARE use)
proc decent_scale_calc_xor {cmdtype cmdddata} {
	set xor [format %02X [expr {0x03 ^ $cmdtype ^ $cmdddata ^ 0x00 ^ 0x00 ^ 0x00}]]
	::bt::msg -DEBUG "decent_scale_calc_xor for '$cmdtype' '$cmdddata' is '$xor'"
	return $xor
}

proc decent_scale_calc_xor4 {cmdtype cmdddata1 cmdddata2} {
	set xor [format %02X [expr {0x03 ^ $cmdtype ^ $cmdddata1 ^ $cmdddata2 ^ 0x00 ^ 0x00}]]
	::bt::msg -DEBUG "decent_scale_calc_xor4 for '$cmdtype' '$cmdddata1' '$cmdddata2' is '$xor'"
	return $xor
}

proc decent_scale_calc_xor8 {cmdtype cmdddata1 cmdddata2 cmdddata3} {
	set xor [format %02X [expr {0x03 ^ $cmdtype ^ $cmdddata1 ^ $cmdddata2 ^ $cmdddata3 ^ 0x00}]]
	::bt::msg -DEBUG "decent_scale_calc_xor4 for '$cmdtype' '$cmdddata1' '$cmdddata2' '$cmdddata3' is '$xor'"
	return $xor
}

proc decent_scale_make_command {cmdtype cmdddata {cmddata2 {}} {cmddata3 {}} } {
	::bt::msg -DEBUG "decent_scale_make_command $cmdtype $cmdddata $cmddata2"
	if {$cmddata2 == ""} {
		# 1 command
		::bt::msg -DEBUG "1 part decent scale command"
		set hex [subst {03${cmdtype}${cmdddata}000000[decent_scale_calc_xor "0x$cmdtype" "0x$cmdddata"]}]
		#set hex2 [subst {03${cmdtype}${cmdddata}000000[decent_scale_calc_xor4 "0x$cmdtype" "0x$cmdddata" "0x00"]}]
	} elseif {$cmddata3 == ""} {
		# 2 commands
		::bt::msg -DEBUG "2 part decent scale command"
		set hex [subst {03${cmdtype}${cmdddata}${cmddata2}0000[decent_scale_calc_xor4 "0x$cmdtype" "0x$cmdddata" "0x$cmddata2"]}]
	} else {
		# 3 commands
		::bt::msg -DEBUG "3 part decent scale command"
		set hex [subst {03${cmdtype}${cmdddata}${cmddata2}${cmddata3}00[decent_scale_calc_xor8 "0x$cmdtype" "0x$cmdddata" "0x$cmddata2" "0x$cmddata3"]}]
	}
	::bt::msg -DEBUG "hex is '$hex' for '$cmdtype' '$cmdddata' '$cmddata2' '$cmddata3'"
	return [binary decode hex $hex]
}

proc tare_counter_incr {} {

	# testing that tare counter can in fact be any not-recently-used integer
	#set ::decent_scale_tare_counter [expr {int(rand() * 255)}]
	#msg "tare counter is $::decent_scale_tare_counter"	

	if {[info exists ::decent_scale_tare_counter] != 1} {
		set ::decent_scale_tare_counter 253
	} elseif {$::decent_scale_tare_counter >= 255} {
		set ::decent_scale_tare_counter 0
	} else {
		incr ::decent_scale_tare_counter
	}
}

proc decent_scale_tare_cmd {} {
	tare_counter_incr
	set cmd [decent_scale_make_command "0F" [format %02X $::decent_scale_tare_counter]]
	return $cmd
}

proc decentscale_enable_notifications {} {
	if {$::de1(scale_device_handle) == 0 || $::settings(scale_type) != "decentscale"} {
		return
	}

	if {[ifexists ::sinstance($::de1(suuid_decentscale))] == ""} {
		::bt::msg -DEBUG "decent scale not connected, cannot enable weight notifications"
		return
	}

	userdata_append "SCALE: enable decent scale weight notifications" [list ble enable $::de1(scale_device_handle) $::de1(suuid_decentscale) $::sinstance($::de1(suuid_decentscale)) $::de1(cuuid_decentscale_read) $::cinstance($::de1(cuuid_decentscale_read))] 1
}

proc decentscale_enable_lcd {} {

	if {$::de1(scale_device_handle) == 0 || $::settings(scale_type) != "decentscale"} {
		return
	}

	if {[ifexists ::sinstance($::de1(suuid_decentscale))] == ""} {
		::bt::msg -DEBUG "decent scale not connected, cannot enable LCD"
		return
	}


	if {$::settings(enable_fluid_ounces) != 1} {
		# grams on display
		set screenon [decent_scale_make_command 0A 01 01 00]
	} else {
		# ounces on display
		set screenon [decent_scale_make_command 0A 01 01 01]
	}
	::bt::msg -DEBUG "decent scale screen on: '[::logging::format_asc_bin $screenon]'"
	userdata_append "SCALE: decentscale : enable LCD" [list ble write $::de1(scale_device_handle) $::de1(suuid_decentscale) $::sinstance($::de1(suuid_decentscale)) $::de1(cuuid_decentscale_write) $::cinstance($::de1(cuuid_decentscale_write)) $screenon] 0
}

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

proc decentscale_timer_start {} {
	if {$::de1(scale_device_handle) == 0 || $::settings(scale_type) != "decentscale"} {
		::bt::msg -DEBUG "decentscale_timer_start - no scale_device_handle"
		return
	}

	if {[ifexists ::sinstance($::de1(suuid_decentscale))] == ""} {
		::bt::msg -DEBUG "decentscale not connected, cannot start timer"
		return
	}

	set ::de1(decentscale_timer_on) 1
	::bt::msg -DEBUG "decentscale_timer_start"
	set timeron [decent_scale_make_command 0B 03 00]
	::bt::msg -DEBUG "decent scale timer on: '[::logging::format_asc_bin $timeron]'"
	userdata_append "SCALE: decentscale : timer on" [list ble write $::de1(scale_device_handle) $::de1(suuid_decentscale) $::sinstance($::de1(suuid_decentscale)) $::de1(cuuid_decentscale_write) $::cinstance($::de1(cuuid_decentscale_write)) $timeron] 0

	# decent scale v1.0 occasionally drops commands, which is being fixed in decent scale v1.1.  
	# So for now we send the same command twice. 
	# In the future we'll check for the decent scale firmare version
	# and only send the command twice if needed for the older decent scale firmware.
	userdata_append "SCALE: decentscale : timer on" [list ble write $::de1(scale_device_handle) $::de1(suuid_decentscale) $::sinstance($::de1(suuid_decentscale)) $::de1(cuuid_decentscale_write) $::cinstance($::de1(cuuid_decentscale_write)) $timeron] 0

}

proc decentscale_timer_stop {} {


	if {$::de1(scale_device_handle) == 0 || $::settings(scale_type) != "decentscale"} {
		return
	}

	if {[ifexists ::sinstance($::de1(suuid_decentscale))] == ""} {
		::bt::msg -DEBUG "decentscale not connected, cannot stop timer"
		return
	}

	::bt::msg -DEBUG "decentscale_timer_stop"

	set ::de1(decentscale_timer_on) 0
	set timeroff [decent_scale_make_command 0B 00 00]
	::bt::msg -DEBUG "decent scale timer stop: '[::logging::format_asc_bin $timeroff]'"
	userdata_append "SCALE: decentscale : timer off" [list ble write $::de1(scale_device_handle) $::de1(suuid_decentscale) $::sinstance($::de1(suuid_decentscale)) $::de1(cuuid_decentscale_write) $::cinstance($::de1(cuuid_decentscale_write)) $timeroff] 0


	# decent scale v1.0 occasionally drops commands, which is being fixed in decent scale v1.1.  
	# So for now we send the same command twice. 
	# In the future we'll check for the decent scale firmare version
	# and only send the command twice if needed for the older decent scale firmware.
	userdata_append "SCALE: decentscale : timer off" [list ble write $::de1(scale_device_handle) $::de1(suuid_decentscale) $::sinstance($::de1(suuid_decentscale)) $::de1(cuuid_decentscale_write) $::cinstance($::de1(cuuid_decentscale_write)) $timeroff] 0

}

proc decentscale_timer_reset {} {

	if {$::de1(scale_device_handle) == 0 || $::settings(scale_type) != "decentscale"} {
		return
	}

	if {[ifexists ::sinstance($::de1(suuid_decentscale))] == ""} {
		::bt::msg -DEBUG "decentscale not connected, cannot RESET timer"
		return
	}


	set timeroff [decent_scale_make_command 0B 02 00]

	::bt::msg -DEBUG "decent scale timer reset: '[::logging::format_asc_bin $timeroff]'"
	userdata_append "SCALE: decentscale : timer reset" [list ble write $::de1(scale_device_handle) $::de1(suuid_decentscale) $::sinstance($::de1(suuid_decentscale)) $::de1(cuuid_decentscale_write) $::cinstance($::de1(cuuid_decentscale_write)) $timeroff] 0


	# decent scale v1.0 occasionally drops commands, which is being fixed in decent scale v1.1.  
	# So for now we send the same command twice. 
	# In the future we'll check for the decent scale firmare version
	# and only send the command twice if needed for the older decent scale firmware.
	userdata_append "SCALE: decentscale : timer reset" [list ble write $::de1(scale_device_handle) $::de1(suuid_decentscale) $::sinstance($::de1(suuid_decentscale)) $::de1(cuuid_decentscale_write) $::cinstance($::de1(cuuid_decentscale_write)) $timeroff] 0
}

proc decentscale_tare {} {
	if {$::de1(scale_device_handle) == 0 || $::settings(scale_type) != "decentscale"} {
		return
	}
	set tare [binary decode hex "10"]

	# if this was a scheduled tare, indicate that the tare has completed
	unset -nocomplain ::scheduled_scale_tare_id

	if {[ifexists ::sinstance($::de1(suuid_decentscale))] == ""} {
		::bt::msg -DEBUG "decent scale not connected, cannot tare"
		return
	}

	set tare [decent_scale_tare_cmd]

	userdata_append "SCALE: decentscale : tare" [list ble write $::de1(scale_device_handle) $::de1(suuid_decentscale) $::sinstance($::de1(suuid_decentscale)) $::de1(cuuid_decentscale_write) $::cinstance($::de1(cuuid_decentscale_write)) $tare] 0


	# decent scale v1.0 occasionally drops commands, which is being fixed in decent scale v1.1.  
	# So for now we send the same command twice. 
	# In the future we'll check for the decent scale firmare version
	# and only send the command twice if needed for the older decent scale firmware.
	userdata_append "SCALE: decentscale : tare" [list ble write $::de1(scale_device_handle) $::de1(suuid_decentscale) $::sinstance($::de1(suuid_decentscale)) $::de1(cuuid_decentscale_write) $::cinstance($::de1(cuuid_decentscale_write)) $tare] 0

}

proc close_all_ble_and_exit {} {
	::bt::msg -NOTICE close_all_ble_and_exit

	###
	### NB: Disconnect events are intentionally not called here
	###

	::bt::msg -DEBUG "close_all_ble_and_exit, at entrance: [ble info]"
	if {$::scanning == 1} {
		catch {
			ble stop $::ble_scanner
		}
	}

	::bt::msg -DEBUG "Closing de1"
	if {$::de1(device_handle) != 0} {
		catch {
			ble close $::de1(device_handle)
		}
	}

	::bt::msg -DEBUG "Closing scale"
	if {$::de1(scale_device_handle) != 0} {
		catch {
			ble close $::de1(scale_device_handle)
		}
	}

	close_misc_bluetooth_handles

	::bt::msg -DEBUG "close_all_ble_and_exit, at exit: [ble info]"
	foreach h [ble info] {
		::bt::msg -INFO "Closing this open BLE handle: [ble info $h]"
		ble close $h
	}
	::bt::msg -DEBUG "close_all_ble_and_exit, at exit: [ble info]"
	foreach h [ble info] {
		::bt::msg -WARNING "Open BLE handle: [ble info $h]"
	}

	::logging::close_logfiles

	exit 0
}

proc app_exit {} {
	::bt::msg -NOTICE app_exit

	if {$::de1(usb_charger_on) != 1} {
		# always leave the app with the charger set to ON
		set ::de1(usb_charger_on) 1
		set_usb_charger_on $::de1(usb_charger_on)
		save_settings
	}

	tcl_introspection

	if {$::android != 1} {
		close_all_ble_and_exit
	}

	# john 1/15/2020 this is a bit of a hack to work around a firmware bug in 7C24F200 that has the ve turn on during sleep, if the fan threshold is set > 0
	if {[firmware_has_fan_sleep_bug] == 1} {
		set_fan_temperature_threshold 0
	}

	set ::exit_app_on_sleep 1
	start_sleep

	# fail-over, if the DE1 doesn't to to sleep
	set since_last_ping [expr {[clock seconds] - $::de1(last_ping)}]
	if {$since_last_ping > 10} {
		# wait less time for the fail-over if we don't have any temperature pings from the DE1
		after 1000 close_all_ble_and_exit
	} else {
		after 5000 close_all_ble_and_exit
	}

	after 5000 { .can itemconfigure $::message_button_label -text [translate "Quit"] }


	after 10000 { ::logging::close_logfiles ; exit 0 }
}

proc de1_read_hotwater {} {
	::bt::msg -NOTICE de1_read_hotwater

	userdata_append "read de1 hot water/steam" [list de1_ble read "ShotSettings"] 1
}

proc de1_read_shot_header {} {
	::bt::msg -NOTICE de1_read_shot_header

	userdata_append "read shot header" [list de1_ble read "HeaderWrite"] 1
}

proc de1_read_shot_frame {} {
	::bt::msg -NOTICE de1_read_shot_frame

	userdata_append "read shot frame" [list de1_ble read "FrameWrite"] 1
}

proc remove_null_terminator {instr} {
	set pos [string first "\x00" $instr]
	if {$pos == -1} {
		return $instr
	}

	incr pos -1
	return [string range $instr 0 $pos]
}

proc android_8_or_newer {} {

	if {$::android != 1} {
		::bt::msg -INFO "android_8_or_newer reports: not android (0)"
		return 0
	}

	catch {
		set x [borg osbuildinfo]
		array set androidprops $x
		::bt::msg -NOTICE [array get androidprops]
		::bt::msg -NOTICE "Android release reported: '$androidprops(version.release)'"
	}
	set test 0
	catch {
		# john note: Android 7 behaves like 8
		set test [expr {$androidprops(version.release) >= 7}]
	}

	return $test
}


proc close_misc_bluetooth_handles {} {
	set count 0
	set handles {}
	catch {
		set handles [ble info]
	}
	foreach handle $handles {
		::bt::msg -NOTICE "Closing misc bluetooth handle $handle"
		catch {
			ble close $handle
		}
		incr count
	}
	return $count

}

set ::ble_scanner {}
set ::scanning -1

if {$::android == 1} {
	# at startup, if we have any hanldes, close them
	set blecount [close_misc_bluetooth_handles]
	if {$blecount != 0} {
		::bt::msg -NOTICE "Closed $blecount misc bluetooth handles"
	}
}

proc check_if_initial_connect_didnt_happen_quickly {} {
	::bt::msg -NOTICE "check_if_initial_connect_didnt_happen_quickly"
	# on initial startup, if a direct connection to DE1 doesn't work quickly, start a scan instead
	set ble_scan_started 0
	if {$::de1(device_handle) == 0 } {
		catch {
			ble close $::currently_connecting_de1_handle

			# TODO: Evaluate: Probably not appropriate to call here
			# as though possibly connected, on_connect hasn't been called

			::de1::event::apply::on_disconnect_callbacks \
				[dict create event_time [expr {[clock milliseconds] / 1000.0}]]
		}
		catch {
			set ::currently_connecting_de1_handle 0
		}
		set ble_scan_started 1
	} else {
		::bt::msg -NOTICE "DE1 device handle is $::de1(device_handle)"
	}

	if {$::settings(scale_bluetooth_address) != "" && $::de1(scale_device_handle) == 0} {
		::bt::msg -NOTICE "on initial startup, if a direct connection to scale doesn't work quickly, start a scan instead"
		catch {
			ble close $::currently_connecting_scale_handle

			# TODO: Evaluate: Probably not appropriate to call here
			# as though possibly connected, on_connect hasn't been called

			::device::scale::event::apply::on_disconnect_callbacks \
				[dict create event_time [expr {[clock milliseconds] / 1000.0}]]

		}
		catch {
			set ::currently_connecting_scale_handle 0
		}
		set ble_scan_started 1
	}


	if {$ble_scan_started == 1} {
		scanning_restart
	}


}

proc stop_scanner {} {

	if {$::scanning != 1} {
		return
	}

	if {$::de1(device_handle) == 0} {
		# don't stop scanning if there is no DE1 connection
		after 30000 stop_scanner
		return
	}

	set ::scanning 0
	::bt::msg -NOTICE "Stopping ble_scanner from ::stop_scanner"
	ble stop $::ble_scanner
}

proc bluetooth_connect_to_devices {} {

	#@return
	::bt::msg -NOTICE "bluetooth_connect_to_devices"

	if {$::android != 1} {
		ble_connect_to_de1
	}

	if {$::settings(bluetooth_address) != ""} {

		if {[android_8_or_newer] == 1} {
			# on bootpup, android 8 won't connect directly to a BLE device unless it's found by a scan
			# this step below waits 4 seconds to see if a direct connection worked, and if not, activates a scan
			# when a scan finds the device, then it will initiate a new connection request and that one will work
			ble_connect_to_de1
			after 4000 check_if_initial_connect_didnt_happen_quickly

			::bt::msg -INFO "will launch check_if_initial_connect_didnt_happen_quickly in 4000ms"
		} else {
			# earlier android revisions can connect directly, and it's fast
			ble_connect_to_de1

		}
	}

	if {$::settings(scale_bluetooth_address) != ""} {

		if {[android_8_or_newer] == 1} {
			#ble_connect_to_scale
		} else {
			#after 3000 ble_connect_to_scale
		}
	}

}


set ::currently_connecting_de1_handle 0
proc ble_connect_to_de1 {} {
	::bt::msg -NOTICE "ble_connect_to_de1"
	#return

	if {$::android != 1} {
		::bt::msg -DEBUG "simulated DE1 connection"
		set ::de1(connect_time) [clock seconds]
		set ::de1(last_ping) [clock seconds]

		::bt::msg -DEBUG "Connected to fake DE1"
		set ::de1(device_handle) 1

		set do_mmr_binary_test 0
		if {$do_mmr_binary_test == 1} {
			# example binary string containing binary version string
			set version_value "\x02\x04\x00\xA4\x0A\x6E\xD0\x68\x51\x02\x04\x00\xA4\x0A\x6E\xD0\x68\x51"
			set ::de1(version) [array get arr2]
			set v [de1_version_string]

			set mmr_test "\x0C\x80\x00\x08\x14\x05\x00\x00\x03\x00\x00\x00\x71\x04\x00\x00\x00\x00\x00\x00"
			::bt::msg -DEBUG [array get arr3]

			#set mmr_test "\x0C\x80\x00\x08\x14\x05\x00\x00\x03\x00\x00\x00\x71\x04\x00\x00\x00\x00\x00\x00"
			parse_binary_mmr_read_int $mmr_test arr4
			::bt::msg -DEBUG [array get arr4]

			::bt::msg -DEBUG "MMR read: CPU board model: '[ifexists arr4(Data0)]'"
			::bt::msg -DEBUG "MMR read: machine model:  '[ifexists arr4(Data1)]'"
			::bt::msg -DEBUG "MMR read: firmware version number: '[ifexists arr4(Data2)]'"

			set ::settings(cpu_board_model) [ifexists arr4(Data0)]
			set ::settings(machine_model) [ifexists arr4(Data1)]
			set ::settings(firmware_version_number) [ifexists arr4(Data2)]
		}

		return
	}

	if {$::settings(bluetooth_address) == ""} {
		# if no bluetooth address set, then don't try to connect
		return ""
	}

	set ::de1(connect_time) 0
	set ::de1(scanning) 0

	if {$::de1(device_handle) != "0"} {
		catch {
			::bt::msg -NOTICE "disconnecting from DE1"
			ble close $::de1(device_handle)
			set ::de1(device_handle) "0"
			::de1::event::apply::on_disconnect_callbacks \
				[dict create event_time [expr {[clock milliseconds] / 1000.0}]]
			after 1000 ble_connect_to_de1
		}
		catch {
			#ble unpair $::settings(bluetooth_address)
		}
	}
	set ::de1(device_handle) 0

	set ::de1_name "DE1"
	if {[catch {
		set ::currently_connecting_de1_handle [ble connect [string toupper $::settings(bluetooth_address)] de1_ble_handler false]
		::bt::msg -NOTICE "Connecting to DE1 on $::settings(bluetooth_address)"
		set retcode 1
	} err] != 0} {
		if {$err == "unsupported"} {
			after 5000 [list info_page [translate "Bluetooth is not on"] [translate "Ok"]]
		}
		::bt::msg -ERROR "Failed to start to BLE connect to DE1 because: '$err'"
		set retcode 0
	}
	return $retcode
}


set ::currently_connecting_scale_handle 0
proc ble_connect_to_scale {} {
	::bt::msg -NOTICE ble_connect_to_scale

	if {$::de1(scale_device_handle) != 0} {
		::bt::msg -NOTICE "Already connected to scale, don't try again"
		return
	}

	#if {[ifexists ::currently_connecting_de1_handle] != 0} {
		#return
	#}


	if {[ifexists ::de1(in_fw_update_mode)] == 1} {
		::bt::msg -NOTICE "in_fw_update_mode : ble_connect_to_scale"
		return
	}


	if {$::settings(scale_bluetooth_address) == ""} {
		::bt::msg -INFO "No Scale BLE address in settings, so not connecting to it"
		return
	}

	if {$::currently_connecting_scale_handle != 0} {
		#::bt::msg -INFO "Already trying to connect to Scale, so don't try again"
		::bt::msg -INFO "Already trying to connect to Scale, so try a reconnect request to see if that helps"

		# it's possible to lose a connection attempt to the scale, so check again in one second, and keep trying until a scale device is found
		#after 1000 ble_connect_to_scale
		#return
		ble reconnect $::currently_connecting_scale_handle
		return 0
	}

	if {[llength $::de1(cmdstack)] > 2} {
		::bt::msg -INFO "Too much backpressure, waiting with the connect"
		::comms::msg -INFO "Current cmd: ([llength $::de1(cmdstack)]) >>>" \
			[lindex [lindex $::de1(cmdstack) 0] 0] 
		
		run_next_userdata_cmd

		after 1000 ble_connect_to_scale
		return
	}

	# 2021-11-25 Johanna: Removed to see if it is the cause for the lunar connection issues
	#remove_matching_ble_queue_entries {^SCALE:}

	if {[catch {
		set ::currently_connecting_scale_handle [ble connect [string toupper $::settings(scale_bluetooth_address)] de1_ble_handler false]
		::bt::msg -NOTICE "Connecting to scale on $::settings(scale_bluetooth_address)"
		set retcode 0
	} err] != 0} {
		set ::currently_connecting_scale_handle 0
		set retcode 1
		::bt::msg -ERROR "Failed to start to BLE connect to scale because: '$err'"
	}
	return $retcode

}

proc append_to_peripheral_list {address name connectiontype devicetype devicefamily} {
	::bt::msg -NOTICE append_to_peripheral_list $name "at" $address

	foreach { entry } $::peripheral_device_list {
		if { [dict get $entry address] eq $address} {
			return
		}
	}

	if { $name == "" } {
		set name $devicefamily
	}

	set newlist $::peripheral_device_list
	lappend newlist [dict create address $address name $name connectiontype $connectiontype devicetype $devicetype devicefamily $devicefamily]

	::bt::msg -INFO "Scan found $connectiontype peripheral: $address ($devicetype:$devicefamily)"
	set ::peripheral_device_list $newlist
	catch {
		fill_peripheral_listbox
	}
}

# mmr_read used
proc later_new_de1_connection_setup {} {
	::bt::msg -NOTICE later_new_de1_connection_setup
	# less important stuff, also some of it is dependent on BLE version

	if {[ifexists ::de1(in_fw_update_mode)] == 1} {
		::bt::msg -NOTICE "in_fw_update_mode : later_new_de1_connection_setup skipped"
		return
	}


	::bt::msg -NOTICE "later_new_de1_connection_setup"
	de1_enable_mmr_notifications


	de1_enable_state_notifications
	get_ghc_is_installed
	de1_send_shot_frames
	set_fan_temperature_threshold $::settings(fan_threshold)
	de1_send_steam_hotwater_settings
	de1_send_waterlevel_settings
	get_3_mmr_cpuboard_machinemodel_firmwareversion
	de1_enable_water_level_notifications
	de1_enable_state_notifications
	de1_enable_temp_notifications

	# not yet ready to implement this, as need to constantly tell the DE1 when user is present, if we do enable this, and also need to show something useful in the UI
	#set_feature_flags 1

	set_heater_tweaks
	get_refill_kit_present

	# if the refill kit auto detect should be overridden, do that at app launch, as well as later in the gui if they change the setting
	if {$::settings(refill_kit_override) != -1} {	
		send_refill_kit_override
	} 

	################
	# we send the flow calibration on app startup to the de1, so that we can calibration the DE1 at the decent factory without needing to power up the DE1.  We set the country-specific calibration in the tablet, and then it will be sent to the DE1 when it powers up
	# 
	# We have an exception here, which is if the settings on the app are set to 1, which is the app default, then it's possible the settings file was just recreated with defaults, and rather than decalibrating the DE1 with a default setting, in that case we
	# fetch the current setting from the DE1
	#
	# We use a three precision 1.000 to differentiate between an intentional 1.00 setting and a default 1.000 setting.  If calbration is changed, it will always be two digits of precision, never 3.
	#
	set calibration_flow_multiplier [ifexists ::settings(calibration_flow_multiplier)]
	if {$calibration_flow_multiplier == "1.000"} {
		# if the flow calibration is set to the default of 1 then fetch the current setting from the machine
		# this should only occur when the settings file was recently deleted and recreated with defaults
		get_calibration_flow_multiplier
	} else {
		set_calibration_flow_multiplier $calibration_flow_multiplier
	}
	################

	after 5000 read_de1_state
	after 7000 get_heater_voltage
	after 9000 de1_enable_temp_notifications
	after 11000 de1_enable_state_notifications

}

proc de1_ble {action command_name {data ""}} {

	if {[ifexists ::sinstance($::de1(suuid))] == ""} {
			::bt::msg -DEBUG "DE1 not connected, cannot send BLE command $command_name"
			return
	}

	eval set current_cuuid $::de1_command_names_to_cuuids($command_name)
	if {$action == "read" || $action == "enable" || $action == "disable"} {
		return [ble $action $::de1(device_handle) $::de1(suuid) $::sinstance($::de1(suuid)) $current_cuuid $::cinstance($current_cuuid)]
	} elseif {$action == "write"} {
		return [ble $action $::de1(device_handle) $::de1(suuid) $::sinstance($::de1(suuid)) $current_cuuid $::cinstance($current_cuuid) $data]
	} else {
		error "Unknown communication action: $action $command_name"
		return 0
	}
}

proc de1_ble_handler { event data } {

	set event_time [expr { [clock milliseconds] / 1000.0 }]

	set full_data_for_log [::logging::format_ble_event $data]

	#
	# For logging, only need some of:
	#   handle ble3
	#   address D9:B2:48:00:49:EF rssi -150 state connected
	#   suuid 0000A000-0000-1000-8000-00805F9B34FB sinstance 12
	#   cuuid 0000A011-0000-1000-8000-00805F9B34FB cinstance 62
	#   duuid 00002902-0000-1000-8000-00805F9B34FB
	#   permissions 0 access w
	#   value {'hex: 01 00'}
	#
	set data_for_log [::logging::format_ble_event_short $data]

	set value_for_log [::logging::format_ble_event_payload $data]

	set ::settings(ble_debug) 0
	if {$::settings(ble_debug) == 1} {
		::bt::msg -DEBUG "ble event: $event $data_for_log"
	}

	set previous_wrote 0
	set previous_wrote [ifexists ::de1(wrote)]
	#set ::de1(wrote) 0

	#set ::de1(last_ping) [clock seconds]

	dict with data {

		switch -- $event {

			scan {
				::bt::msg -DEBUG "de1_ble_handler: Device $name found at address $address ($data_for_log)"

				if {[string first DE1 $name] == 0} {
					append_to_de1_list $address $name "ble"
					#if {$address == $::settings(bluetooth_address) && $::scanning != 0} {
						#ble stop $::ble_scanner
						#set ::scanning 0
						#ble_connect_to_de1
					#}
					if {$address == $::settings(bluetooth_address)} {
						if {$::currently_connecting_de1_handle == 0} {
							::bt::msg -INFO "Not currently connecting to DE1, so trying now"
							ble_connect_to_de1
						} else {
							#catch {
								#ble close $::currently_connecting_de1_handle
							#}
							#ble_connect_to_de1
						}
					}
				} elseif {[string first Skale $name] == 0} {
					append_to_peripheral_list $address $name "ble" "scale" "atomaxskale"

				} elseif {[string first "Decent Scale" $name] == 0} {
					append_to_peripheral_list $address $name "ble" "scale" "decentscale"

				} elseif {[string first "FELICITA" $name] == 0} {
					append_to_peripheral_list $address $name "ble" "scale" "felicita"

 				} elseif {[string first "HIROIA JIMMY" $name] == 0} {
					append_to_peripheral_list $address $name "ble" "scale" "hiroiajimmy"

 				} elseif {[string first "CFS-9002" $name] == 0} {
					append_to_peripheral_list $address $name "ble" "scale" "eureka_precisa"

 				} elseif {[string first "ACAIA" $name] == 0 \
 					|| [string first "PROCH" $name]    == 0 } {
					append_to_peripheral_list $address $name "ble" "scale" "acaiascale"
					
				} elseif {[string first "PEARLS" $name] == 0 \
 					|| [string first "LUNAR" $name]    == 0 \
 					|| [string first "PYXIS" $name]    == 0 } {
					append_to_peripheral_list $address $name "ble" "scale" "acaiapyxis"
				} else {
					return
				}
				if {$address == $::settings(scale_bluetooth_address)} {
					if {$::currently_connecting_scale_handle == 0} {
						::bt::msg -INFO "Not currently connecting to scale, so trying now"
						ble_connect_to_scale
					}
				}
			}
			connection {
				if {$state eq "disconnected"} {
					if {$address == $::settings(bluetooth_address)} {
						# fall back to scanning

						de1_disconnect_handler $handle

					} elseif {$address == $::settings(scale_bluetooth_address)} {
						set ::de1(wrote) 0
						::bt::msg -NOTICE "scale $::settings(scale_type) disconnected $data_for_log"
						#catch {
							ble close $handle
						#}

						# if the skale connection closed in the currentl one, then reset it
						if {$handle == $::de1(scale_device_handle)} {
							set ::de1(scale_device_handle) 0
						}

						if {$::currently_connecting_scale_handle == 0} {
							#ble_connect_to_scale
						}

						catch {
							ble close $::currently_connecting_scale_handle
						}

						set ::currently_connecting_scale_handle 0
						# 2021-11-25 Johanna: Removed to see if it is the cause for the lunar connection issues
						#remove_matching_ble_queue_entries {^SCALE:}

						set event_dict [dict create \
									event_time $event_time \
									address $address \
								       ]

						::device::scale::event::apply::on_disconnect_callbacks $event_dict

						if {$::de1(bluetooth_scale_connection_attempts_tried) < 20} {
							incr ::de1(bluetooth_scale_connection_attempts_tried)
							::bt::msg -INFO "Disconnected from scale, trying again automatically.  Attempts=$::de1(bluetooth_scale_connection_attempts_tried)"
							ble_connect_to_scale
						} else {
							# after 5 minutes, reset the scale retrier count back to zero that when coming back 
							# to the DE1 after some time away, we can again retry scale connection 
							::bt::msg -INFO "Resetting scale connect retries back to zero, after 300 second waiting"
							after 300000 "set ::de1(bluetooth_scale_connection_attempts_tried) 0"
						}
					}
				} elseif {$state eq "scanning"} {
					set ::scanning 1
					::bt::msg -DEBUG "de1_ble_handler is scanning"
				} elseif {$state eq "idle"} {
					#ble stop $::ble_scanner
					if {$::scanning > 0} {

						if {$::de1(device_handle) == 0 && $::currently_connecting_de1_handle == 0} {
							ble_connect_to_de1
						}

					}
					set ::scanning 0
				} elseif {$state eq "discovery"} {
					#ble_connect_to_de1
				} elseif {$state eq "connected"} {

					# testing "ble mtu" command http://www.androwish.org/index.html/info/d990702552f12a0a
					# set mtu [ble mtu $handle] 
					# ::bt::msg -NOTICE "DE1 BLE mtu is $mtu"
					# set mtu1 [ble mtu $handle 4096] 
					# ::bt::msg -NOTICE "DE1 BLE mtu set result was $mtu1"
					# set mtu2 [ble mtu $handle] 
					# :bt::msg -NOTICE "DE1 BLE mtu is now $mtu2"


					if {[info exists address] != 1} {
						# this is very odd, no address yet connected
						::bt::msg -NOTICE "full bluetooth log: $full_data_for_log"
						return
					}

					if {$::de1(device_handle) == 0 && $address == $::settings(bluetooth_address)} {
						::bt::msg -NOTICE "de1 connected $event $data_for_log"

						::de1::event::apply::on_connect_callbacks \
							[dict create event_time [expr {[clock milliseconds] / 1000.0}]]

						de1_connect_handler $handle $address "DE1"

						if {$::de1(scale_device_handle) != 0} {
							# if we're connected to both the scale and the DE1, stop scanning (or if there is not scale to connect to and we're connected to the de1)
							stop_scanner
						}

					} elseif {$::de1(scale_device_handle) == 0 && $address == $::settings(scale_bluetooth_address)} {

						set ::de1(wrote) 0
						set ::de1(scale_device_handle) $handle
						set ::de1(bluetooth_scale_connection_attempts_tried) 0

						# resend the hotwater settings, because now we can stop on weight
						after 7000 de1_send_steam_hotwater_settings

						::bt::msg -NOTICE "scale '$::settings(scale_type)' connected $::de1(scale_device_handle)" \
							"$handle - $event $data_for_log"
						if {$::settings(scale_type) == ""} {
							::bt::msg -ERROR "blank scale type found, reset to atomaxskale"
							set ::settings(scale_type) "atomaxskale"
						}

						if {$::settings(scale_type) == "decentscale"} {
							append_to_peripheral_list $address $::settings(scale_bluetooth_name) "ble" "scale" "decentscale"

							after 100 decentscale_enable_lcd
							after 200 decentscale_enable_notifications
							after 300 decentscale_enable_notifications
							
							# in case the first request was dropped
							after 400 decentscale_enable_lcd

						} elseif {$::settings(scale_type) == "atomaxskale"} {
							append_to_peripheral_list $address $::settings(scale_bluetooth_name) "ble" "scale" "atomaxskale"
							#set ::de1(scale_type) "atomaxskale"

							# atomax Bluetooth has a bug where battery level is always reported as 100%, so no point
							# in fetching it.  Setting it to as-if-usb-powered because that's how most people use it.
							set ::de1(scale_battery_level) 100
							set ::de1(scale_usb_powered) 1

							skale_enable_lcd
							after 1000 skale_enable_weight_notifications
							after 2000 skale_enable_button_notifications
							after 3000 skale_enable_lcd
						} elseif {$::settings(scale_type) == "felicita"} {
							append_to_peripheral_list $address $::settings(scale_bluetooth_name) "ble" "scale" "felicita"
							after 2000 felicita_enable_weight_notifications
						} elseif {$::settings(scale_type) == "hiroiajimmy"} {
							append_to_peripheral_list $address $::settings(scale_bluetooth_name) "ble" "scale" "hiroiajimmy"
							after 200 hiroia_enable_weight_notifications
						} elseif {$::settings(scale_type) == "eureka_precisa"} {
							append_to_peripheral_list $address $::settings(scale_bluetooth_name) "ble" "scale" "eureka_precisa"
							after 200 eureka_precisa_enable_weight_notifications
						} elseif {$::settings(scale_type) == "acaiascale"} {
							append_to_peripheral_list $address $::settings(scale_bluetooth_name) "ble" "scale" "acaiascale"
							set ::settings(force_acaia_heartbeat) 0

							if { [string first "PROCH" $::settings(scale_bluetooth_name)] != -1 } {
								set ::settings(force_acaia_heartbeat) 1
							}

							acaia_send_ident $::de1(suuid_acaia_ips) $::de1(cuuid_acaia_ips_age)
							after 500 [list acaia_send_config $::de1(suuid_acaia_ips) $::de1(cuuid_acaia_ips_age)]
							after 1000 [list acaia_enable_weight_notifications $::de1(suuid_acaia_ips) $::de1(cuuid_acaia_ips_age)]
							after 2000 [list acaia_send_heartbeat $::de1(suuid_acaia_ips) $::de1(cuuid_acaia_ips_age)]
						} elseif {$::settings(scale_type) == "acaiapyxis"} {
							append_to_peripheral_list $address $::settings(scale_bluetooth_name) "ble" "scale" "acaiapyxis"
							msg -INFO "Pyxis scale showed up"

							if {[ifexists ::sinstance($::de1(suuid_acaia_pyxis))] == {}} {
								msg -NOTICE "fake connction to acaia scale. Closing handle again"
								#ble close $handle
								#ble_connect_to_scale
								#return
							}

							set ::settings(force_acaia_heartbeat) 1
							set mtu1 [ble mtu $handle 247]
							msg -INFO "MTU is $mtu1"
							after 2000 [list acaia_enable_weight_notifications $::de1(suuid_acaia_pyxis) $::de1(cuuid_acaia_pyxis_status)]
							after 2500  [list acaia_send_ident $::de1(suuid_acaia_pyxis) $::de1(cuuid_acaia_pyxis_cmd)]
							after 3000 [list acaia_send_config $::de1(suuid_acaia_pyxis) $::de1(cuuid_acaia_pyxis_cmd)]
							after 4500 [list acaia_send_heartbeat $::de1(suuid_acaia_pyxis) $::de1(cuuid_acaia_pyxis_cmd)]
						} else {
							error "unknown scale: '$::settings(scale_type)'"
						}
						set ::currently_connecting_scale_handle 0

						if {$::de1(device_handle) != 0} {
							# if we're connected to both the scale and the DE1, stop scanning
							stop_scanner
						}

						set event_dict [dict create \
									event_time $event_time \
									address $address \
								       ]

						::device::scale::event::apply::on_connect_callbacks $event_dict

					} else {
						::bt::msg -ERROR "doubled connection notification from $address, already connected with $address"
						#ble close $handle
					}


				} else {
					::bt::msg -ERROR "unknown connection msg: $data_for_log"
				}
			}
			transaction {
				::bt::msg -INFO "ble transaction result $event $data_for_log"
			}

			characteristic {
				if {$state eq "discovery"} {
					# save the mapping because we now need it for Android 7
					set ::cinstance($cuuid) $cinstance
					set ::sinstance($suuid) $sinstance
				} elseif {$state eq "connected"} {

					if {$access eq "r" || $access eq "c"} {
						if {$access eq "r"} {
							set ::de1(wrote) 0
							run_next_userdata_cmd
						}

						if {$suuid eq $::de1(suuid) \
							&& [info exists ::de1_cuuids_to_command_names($cuuid)]} {
							eval set command_name $::de1_cuuids_to_command_names($cuuid)
							de1_event_handler $command_name [dict get $data value]
							return
						}

						if {$cuuid eq $::de1(cuuid_0D)} {
							set ::de1(last_ping) [clock seconds]
							::de1::state::update::from_shotvalue $value $event_time
							set do_this 0
							if {$do_this == 1} {
								# this tries to handle bad write situations, but it might have side effects if it is not working correctly.
								# probably this should be adding a command to the top of the write queue
								if {$previous_wrote == 1} {
									::bt::msg -ERROR "bad write reported"
									{*}$::de1(previouscmd)
									set ::de1(wrote) 1
									return
								}
							}
					} elseif {$cuuid eq $::de1(cuuid_05)} {
							# MMR read
					    ::bt::msg -INFO "MMR read: [::logging::format_mmr $value]"

							parse_binary_mmr_read $value arr
							set mmr_id $arr(Address)
							set mmr_val [ifexists arr(Data0)]

							parse_binary_mmr_read_int $value arr2

							if {$mmr_id == "80381C"} {
								::bt::msg -INFO "Read: GHC is installed: '$mmr_val'"
								set ::settings(ghc_is_installed) $mmr_val

								if {$::settings(ghc_is_installed) == 1 || $::settings(ghc_is_installed) == 2} {
									# if the GHC is present but not active, check back every 10 minutes to see if its status has changed
									# this is only relevant if the machine is in a debug GHC mode, where the DE1 acts as if the GHC
									# is not there until it is touched. This allows the tablet to start operations.  If (or once) the GHC is
									# enabled, only the GHC can start operations.
									after 600000 get_ghc_is_installed
								}

							} elseif {$mmr_id == "803808"} {
								set ::de1(fan_threshold) $mmr_val
								set ::settings(fan_threshold) $mmr_val
								::bt::msg -INFO "MMR read: Fan threshold: '$mmr_val'"
							} elseif {$mmr_id == "80380C"} {
								::bt::msg -INFO "MMR read: tank temperature threshold: '$mmr_val'"
								set ::de1(tank_temperature_threshold) $mmr_val
							} elseif {$mmr_id == "803820"} {
								::bt::msg -INFO "MMR read: group head control mode: '$mmr_val'"
								set ::settings(ghc_mode) $mmr_val
							} elseif {$mmr_id == "803828"} {
								::bt::msg -INFO "MMR read: steam flow: '$mmr_val'"
								set ::settings(steam_flow) $mmr_val
							} elseif {$mmr_id == "803818"} {
								::bt::msg -INFO "MMR read: hot_water_idle_temp: '[ifexists arr2(Data0)]'"
								set ::settings(hot_water_idle_temp) [ifexists arr2(Data0)]

								#mmr_read "espresso_warmup_timeout" "803838" "00"
							} elseif {$mmr_id == "803838"} {
								::bt::msg -INFO "MMR read: espresso_warmup_timeout: '[ifexists arr2(Data0)]'"
								set ::settings(espresso_warmup_timeout) [ifexists arr2(Data0)]
							} elseif {$mmr_id == "80383C"} {
								::bt::msg -INFO "MMR read: flow estimate multiplier: '[ifexists arr2(Data0)]' = [round_to_two_digits [expr {[ifexists arr2(Data0)] / 1000.0}]]"
								set ::settings(calibration_flow_multiplier) [round_to_two_digits [expr {[ifexists arr2(Data0)] / 1000.0}]]
							} elseif {$mmr_id == "803810"} {
								::bt::msg -INFO "MMR read: phase_1_flow_rate: '[ifexists arr2(Data0)]'"
								set ::settings(phase_1_flow_rate) [ifexists arr2(Data0)]

								if {[ifexists arr(Len)] >= 4} {
								::bt::msg -INFO "MMR read: phase_2_flow_rate: '[ifexists arr2(Data1)]'"
									set ::settings(phase_2_flow_rate) [ifexists arr2(Data1)]
								}
								if {[ifexists arr(Len)] >= 8} {
									::bt::msg -INFO "MMR read: hot_water_idle_temp: '[ifexists arr2(Data2)]'"
									set ::settings(hot_water_idle_temp) [ifexists arr2(Data2)]
								}

							} elseif {$mmr_id == "803834"} {

								::bt::msg -INFO "MMR read: heater voltage: '[ifexists arr2(Data0)]' len=[ifexists arr(Len)]"
								set ::settings(heater_voltage) [ifexists arr2(Data0)]

								catch {
									if {[ifexists ::settings(firmware_version_number)] != ""} {
										if {$::settings(firmware_version_number) >= 1142} {
											if {$::settings(heater_voltage) == 0} {
												::bt::msg -WARNING "Heater voltage is unknown, please set it"
												show_settings calibrate2
											}
										}
									}
								}

								if {[ifexists arr(Len)] >= 8} {
									::bt::msg -INFO "MMR read: espresso_warmup_timeout2: '[ifexists arr2(Data1)]'"
									set ::settings(espresso_warmup_timeout) [ifexists arr2(Data1)]

									mmr_read "phase_1_flow_rate" "803810" "02"
								}


							} elseif {$mmr_id == "800008"} {

								if {[ifexists arr(Len)] == 12} {
									# it's possibly to read all 3 MMR characteristics at once

									# CPU Board Model * 1000. eg: 1100 = 1.1
									::bt::msg -INFO "MMR read: CPU board model: '[ifexists arr2(Data0)]'"
									set ::settings(cpu_board_model) [ifexists arr2(Data0)]

									# v1.3+ Firmware Model (Unset = 0, DE1 = 1, DE1Plus = 2, DE1Pro = 3, DE1XL = 4, DE1Cafe = 5)
									::bt::msg -INFO "MMR read: machine model:  '[ifexists arr2(Data1)]'"
									set ::settings(machine_model) [ifexists arr2(Data1)]

									# CPU Board Firmware build number. (Starts at 1000 for 1.3, increments by 1 for every build)
									::bt::msg -INFO "MMR read: firmware version number: '[ifexists arr2(Data2)]'"
									set ::settings(firmware_version_number) [ifexists arr2(Data2)]

								} else {
									# CPU Board Model * 1000. eg: 1100 = 1.1
									::bt::msg -INFO "MMR read: CPU board model: '[ifexists arr2(Data0)]'"
									set ::settings(cpu_board_model) [ifexists arr2(Data0)]
								}

							} elseif {$mmr_id == "80000C"} {
								parse_binary_mmr_read_int $value arr2

								# v1.3+ Firmware Model (Unset = 0, DE1 = 1, DE1Plus = 2, DE1Pro = 3, DE1XL = 4, DE1Cafe = 5)
								::bt::msg -INFO "MMR read: machine model:  '[ifexists arr2(Data0)]'"
								set ::settings(machine_model) [ifexists arr2(Data0)]

							} elseif {$mmr_id == "800010"} {
								parse_binary_mmr_read_int $value arr2

								# CPU Board Firmware build number. (Starts at 1000 for 1.3, increments by 1 for every build)
								::bt::msg -INFO "MMR read: firmware version number: '[ifexists arr2(Data0)]'"
								set ::settings(firmware_version_number) [ifexists arr2(Data0)]

							} elseif {$mmr_id == "80382C"} {
								::bt::msg -INFO "MMR read: steam_highflow_start: '$mmr_val'"
								set ::settings(steam_highflow_start) $mmr_val
							} elseif {$mmr_id == "80385C"} {
								::bt::msg -INFO "MMR read: steam_highflow_start: '$mmr_val'"
								set ::de1(refill_kit_detected) $mmr_val
							} else {
							    ::bt::msg -ERROR "Uknown type of direct MMR read" \
								    [::logging::format_mmr $value]
							}

						} elseif {$cuuid eq $::de1(cuuid_01)} {
							set ::de1(last_ping) [clock seconds]
							parse_binary_version_desc $value arr2
							::bt::msg -INFO "version data received: '$data_for_log'"
							set ::de1(version) [array get arr2]

							set v [de1_version_string]

							# run stuff that depends on the BLE API version
							later_new_de1_connection_setup

							set ::de1(wrote) 0
							run_next_userdata_cmd

						} elseif {$cuuid eq $::de1(cuuid_12)} {
							calibration_ble_received $value
						} elseif {$cuuid eq $::de1(cuuid_11)} {
							set ::de1(last_ping) [clock seconds]
							parse_binary_water_level $value arr2

							# compensate for the fact that we measure water level a few mm higher than the water uptake point
							set mm [expr {$arr2(Level) + $::de1(water_level_mm_correction)}]
							set ::de1(water_level) $mm

						} elseif {$cuuid eq $::de1(cuuid_09)} {
							parse_map_request $value arr2
							#
							# TODO: These messages need clarification
							#
							::bt::msg -INFO "a009: [array get arr2]"
							if {$::de1(currently_erasing_firmware) == 1 && [ifexists arr2(FWToErase)] == 0} {
								::bt::msg -NOTICE "BLE recv: finished erasing fw '[ifexists arr2(FWToMap)]'"
								set ::de1(currently_erasing_firmware) 0
							} elseif {$::de1(currently_erasing_firmware) == 1 && [ifexists arr2(FWToErase)] == 1} {
								::bt::msg -NOTICE "BLE recv: currently erasing fw '[ifexists arr2(FWToMap)]'"
							} elseif {$::de1(currently_erasing_firmware) == 0 && [ifexists arr2(FWToErase)] == 0} {
								::bt::msg -ERROR "BLE firmware find error BLE recv: [array get arr2] '$value_for_log'"

								if {[ifexists arr2(FirstError1)] == [expr 0xFF] && [ifexists arr2(FirstError2)] == [expr 0xFF] && [ifexists arr2(FirstError3)] == [expr 0xFD]} {
									set ::de1(firmware_update_button_label) "Updated"
								} else {
									set ::de1(firmware_update_button_label) "Update failed"
								}
								set ::de1(currently_updating_firmware) 0

							} else {
								::bt::msg -ERROR "unknown firmware cmd ack recvied: '$data_for_log'"
							}
						} elseif {$cuuid eq $::de1(cuuid_0B)} {
							set ::de1(last_ping) [clock seconds]
							parse_binary_hotwater_desc $value arr2
							::bt::msg -INFO "hotwater data received: [array get arr2] ($data_for_log)"
						} elseif {$cuuid eq $::de1(cuuid_0C)} {
							set ::de1(last_ping) [clock seconds]
							parse_binary_shot_desc $value arr2
							::bt::msg -INFO "shot data received: [array get arr2] ($data_for_log)"
						} elseif {$cuuid eq $::de1(cuuid_0F)} {
							set ::de1(last_ping) [clock seconds]
							parse_binary_shotdescheader $value arr2
							::bt::msg -INFO "READ shot header success:: [array get arr2] ($data_for_log)"
						} elseif {$cuuid eq $::de1(cuuid_10)} {
							set ::de1(last_ping) [clock seconds]
							parse_binary_shotframe $value arr2
							::bt::msg -INFO "shot frame received: [array get arr2] ($data_for_log)"
						} elseif {$cuuid eq $::de1(cuuid_0E)} {
							set ::de1(last_ping) [clock seconds]
							update_de1_state $value

							set ::de1(wrote) 0
							run_next_userdata_cmd

						} elseif {$cuuid eq $::de1(cuuid_decentscale_writeback)} {
							# decent scale
							#::bt::msg -INFO "Decentscale writeback received"
							parse_decent_scale_recv $value vals

						} elseif {$cuuid eq $::de1(cuuid_skale_EF81)} {
							# Atomax scale
							binary scan $value cus1cu t0 t1 t2 t3 t4 t5
							set sensorweight [expr {$t1 / 10.0}]
							::device::scale::process_weight_update $sensorweight $event_time

						} elseif {$cuuid eq $::de1(cuuid_decentscale_read)} {
							# decent scale

							#::bt::msg -INFO "Decentscale read received"
							parse_decent_scale_recv $value weightarray

							if {[ifexists weightarray(command)] == [expr 0x0F] && [ifexists weightarray(data6)] == [expr 0xFE]} {
								# tare cmd success is a msg back to us with the tare in 'command', and a byte6 of 0xFE
								::bt::msg -INFO "ACK decent scale: tare"

								return
							} elseif {[ifexists weightarray(command)] == 0xAA} {
								::bt::msg -INFO "Decentscale BUTTON $weightarray(data3) pressed ([array get weightarray])-([ifexists weightarray(data3)])"
								if {[ifexists weightarray(data3)] == 1} {
									# button 1 "O" pressed
									::bt::msg -INFO "Decentscale TARE BUTTON pressed"
									decentscale_tare
								} elseif {[ifexists weightarray(data3)] == 2} {
									# button 2 "[]" pressed
									if {$::de1(decentscale_timer_on) == 1} {
										::bt::msg -INFO "Decentscale TIMER STOP BUTTON pressed"
										decentscale_timer_stop
									} else {
										::bt::msg -INFO "Decentscale TIMER RESET/START BUTTON pressed"
										decentscale_timer_reset
										after 500 decentscale_timer_start
									}
								} 
							} elseif {[ifexists weightarray(command)] == 0x0A} {
								::bt::msg -INFO "decentscale LED callback recv: [array get weightarray]"								
								set ::de1(scale_fw_version) [ifexists weightarray(data6)]
								set ::de1(scale_battery_level) [ifexists weightarray(data5)]
								if {$::de1(scale_battery_level) > 100} {
									set ::de1(scale_battery_level) 100
									set ::de1(scale_usb_powered) 1
								}

								::bt::msg -INFO "decentscale battery: $::de1(scale_battery_level)"								
								::bt::msg -INFO "decentscale usb powered: $::de1(scale_usb_powered)"								
								::bt::msg -INFO "decentscale firmware version: $::de1(scale_fw_version)"								

							} elseif {[info exists weightarray(weight)] == 1} {
								set sensorweight [expr {$weightarray(weight) / 10.0}]
								::device::scale::process_weight_update $sensorweight $event_time
							 	if {[info exists weightarray(timestamp)] == 1} {
									set ::de1(scale_timestamp) $weightarray(timestamp)				
									#set ::de1(scale_minutes) $weightarray(minutes)				
									#set ::de1(scale_seconds) $weightarray(seconds)				
									#set ::de1(scale_milliseconds) $weightarray(milliseconds)				
									#::bt::msg -INFO "decentscale timestamp: $::de1(scale_timestamp) - $weightarray(minutes):$weightarray(minutes):$weightarray(milliseconds) [array get weightarray]"
								}
							} else {
								::bt::msg -INFO "decentscale recv: [array get weightarray]"
							}
						} elseif {$cuuid eq $::de1(cuuid_acaia_ips_age)} {
							# acaia scale (gen 1, fw 2)
							acaia_parse_response $value
						} elseif {$cuuid eq $::de1(cuuid_acaia_pyxis_status)} {
							# acaia scale (gen 2, fw 1)
							acaia_parse_response $value
						} elseif {$cuuid eq $::de1(cuuid_felicita)} {
							# felicita scale
							felicita_parse_response $value
						} elseif {$cuuid eq $::de1(cuuid_hiroiajimmy_status)} {
							# hiroia jimmy scale
							hiroia_parse_response $value
						} elseif {$cuuid eq $::de1(cuuid_eureka_precisa_status)} {
							# eureka precisa scale
							eureka_precisa_parse_response $value
						} elseif {$cuuid eq $::de1(cuuid_skale_EF82)} {
							set t0 {}
							#set t1 {}
							binary scan $value cucucucucucu t0 t1
							::bt::msg -INFO "Skale button pressed: $t0 : DE1 state: $::de1(state) = $::de1_num_state($::de1(state)) "

							if {$t0 == 1} {
								scale_tare
							} elseif {$t0 == 2} {
								if {$::settings(scale_button_starts_espresso) == 1} {
									 if {$::de1_num_state($::de1(state)) == "Espresso"} {
										say [translate {Stop}] $::settings(sound_button_in)
										start_idle
									} else {
										say [translate {Espresso}] $::settings(sound_button_in)
										start_espresso
									}
								}
							}

						} else {
						    ::bt::msg -ERROR "ACK unknown read from DE1" \
							    "[::logging::short_ble_uuid $cuuid]: $value_for_log"
						}

					} elseif {$access eq "w"} {
						set ::de1(wrote) 0
						run_next_userdata_cmd

						if {$cuuid eq $::de1(cuuid_05)} {

						    ::bt::msg -INFO "ACK MMR read request" \
							    [::logging::format_mmr $value]

						} elseif {$cuuid eq $::de1(cuuid_10)} {
							parse_binary_shotframe $value arr3
							::bt::msg -INFO "ACK shot frame written to DE1: [array get arr3] ($data_for_log)"

							# keep track of what frames were acked as sent, so we can later make sure all were indeed acked
							lappend ::de1(shot_frames_sent) [array get arr3]
						} elseif {$cuuid eq $::de1(cuuid_11)} {
							parse_binary_water_level $value arr2
							::bt::msg -INFO "ACK water level write: [array get arr2] ($data_for_log)"
						} elseif {$cuuid eq $::de1(cuuid_decentscale_writeback)} {
							::bt::msg -INFO "ACK decentscale write back: '$value_for_log'"
						} elseif {$cuuid eq $::de1(cuuid_decentscale_write)} {
							::bt::msg -INFO "ACK decentscale write: '$value_for_log'"
						} elseif {$cuuid eq $::de1(cuuid_skale_EF80)} {
							set tare [binary decode hex "10"]
							set grams [binary decode hex "03"]
							set screenon [binary decode hex "ED"]
							set displayweight [binary decode hex "EC"]
							if {$value == $tare } {
							    ::bt::msg -INFO "ACK Skale: tare"

							} elseif {$value == $grams } {
								::bt::msg -INFO "ACK Skale: grams"
							} elseif {$value == $screenon } {
								::bt::msg -INFO "ACK Skale: screen on"
							} elseif {$value == $displayweight } {
								::bt::msg -INFO "ACK Skale: display weight"
							} elseif {$value == [binary decode hex "d0"] } {
								::bt::msg -INFO "ACK Skale: timer reset"
							} elseif {$value == [binary decode hex "d1"] } {
								::bt::msg -INFO "ACK Skale: timer stop"
							} elseif {$value == [binary decode hex "dd"] } {
								::bt::msg -INFO "ACK Skale: timer start"
							} elseif {$value == [binary decode hex "ee"] } {
								::bt::msg -INFO "ACK Skale: screen off"
							} else {
								::bt::msg -ERROR [format "Skale: write received: %s (unrecognized)" \
										      [binary encode hex $value]]
							}
						} else {
							if {$address == $::settings(bluetooth_address)} {
								if {$cuuid eq $::de1(cuuid_02)} {
									parse_state_change $value arr
									::bt::msg -INFO "ACK state change written to DE1: '[array get arr]'"
								} elseif {$cuuid eq $::de1(cuuid_06)} {
									if {$::de1(currently_erasing_firmware) == 1 && $::de1(currently_updating_firmware) == 0} {
										::bt::msg -INFO "firmware erase write ack recved: [string length $value] bytes: $value : [array get arr2]"
									} elseif {$::de1(currently_erasing_firmware) == 0 && $::de1(currently_updating_firmware) == 1} {

										::bt::msg -INFO "ACK firmware write:" \
											[::logging::format_mmr_short $value]
										firmware_upload_next
									} else {
										::bt::msg -INFO "ACK MMR write [::logging::format_mmr $value]"
									}
								} elseif {$cuuid eq $::de1(cuuid_09) && $::de1(currently_erasing_firmware) == 1} {
									::bt::msg -INFO "fw request to erase sent"
								} else {
								    ::bt::msg -INFO "ACK wrote to" \
									    [::logging::short_ble_uuid $cuuid] \
									    "of DE1: '$value_for_log'"
								}
							} elseif {$address == $::settings(scale_bluetooth_address)} {
							    ::bt::msg -INFO "ACK wrote to" \
							    [::logging::short_ble_uuid $cuuid] \
								    "of $::settings(scale_type): '$value_for_log'"
							} else {
								::bt::msg -ERROR "ACK for write to" \
									[::logging::short_ble_uuid $cuuid] \
									"of unknown device: '$value_for_log'"
							}
						}


					} else {
						::bt::msg -ERROR "weird characteristic received: $data_for_log"
					}

				}
			}
			service {

			}
			descriptor {

				if {$state eq "connected"} {

					if {$access eq "w"} {

					    if {$cuuid eq $::de1(cuuid_0D)} {
						::bt::msg -INFO "ACK DE1 temperature notifications: $data_for_log"

					    } elseif {$cuuid eq $::de1(cuuid_0E)} {
						::bt::msg -INFO "ACK DE1 state change notifications: $data_for_log"

					    } elseif {$cuuid eq $::de1(cuuid_12)} {
						::bt::msg -INFO "ACK DE1 calibration notifications: $data_for_log"

					    } elseif {$cuuid eq $::de1(cuuid_05)} {
						::bt::msg -INFO "ACK MMR write notifications: $data_for_log"

					    } elseif {$cuuid eq $::de1(cuuid_11)} {
						::bt::msg -INFO "ACK water level write: $data_for_log"

					    } elseif {$cuuid eq $::de1(cuuid_skale_EF81)} {
						::bt::msg -INFO "ACK Skale weight notifications: $data_for_log"

					    } elseif {$cuuid eq $::de1(cuuid_skale_EF82)} {
						::bt::msg -INFO "ACK Skale button notifications: $data_for_log"

					    } elseif {$cuuid eq $::de1(cuuid_acaia_ips_age)} {
						::bt::msg -INFO "ACK Acaia Lunar notifications: $data_for_log"

					    } elseif {$cuuid eq $::de1(cuuid_acaia_pyxis_status)} {
						::bt::msg -INFO "ACK Acaia Pyxis notifications: $data_for_log"

					    } else {
						::bt::msg -ERROR "ACK Descriptor unknown write: $data_for_log"
					    }

					    set ::de1(wrote) 0
					    run_next_userdata_cmd

					} else {
					    ::bt::msg -ERROR "BLE unknown descriptor action; $state: ${event}: ${data_for_log}"
					}

					set run_this 0

					if {$run_this == 1} {
						set lst [ble userdata $handle]
						set cmds [unshift lst]
						ble userdata $handle $lst
						::bt::msg -DEBUG "$cmds"
						if {$cmds ne {}} {
							set cmd [lindex $cmds 0]
							set cmds [lrange $cmds 1 end]
							{*}[lindex $cmd 1]
							ble userdata $handle $cmds
						}
					}
				} else {
					#
				}

			}

			default {
				::bt::msg -ERROR "ble unknown callback $event $data_for_log"
			}
		}
	}
}

# john 1/15/2020 this is a bit of a hack to work around a firmware bug in 7C24F200 that has the fan turn on during sleep, if the fan threshold is set > 0
proc firmware_has_fan_sleep_bug {} {

	if {[ifexists ::settings(firmware_sha)] == "7C24F200"} {
		return 1
	}

	if {[ifexists ::settings(firmware_version_number)] != ""} {
		if {$::settings(firmware_version_number) <= 1174} {
			return 1
		}
	}

	return 0

}

proc calibration_ble_received {value} {

	#calibration_ble_received $value
	parse_binary_calibration $value arr2

	set varname ""
	if {[ifexists arr2(CalTarget)] == 0} {
		if {[ifexists arr2(CalCommand)] == 3} {
			set varname	"factory_calibration_flow"
		} else {
			set varname	"calibration_flow"
		}
	} elseif {[ifexists arr2(CalTarget)] == 1} {
		if {[ifexists arr2(CalCommand)] == 3} {
			set varname	"factory_calibration_pressure"
		} else {
			set varname	"calibration_pressure"
		}
	} elseif {[ifexists arr2(CalTarget)] == 2} {
		if {[ifexists arr2(CalCommand)] == 3} {
			set varname	"factory_calibration_temperature"
		} else {
			set varname	"calibration_temperature"
		}
	}

	set _readable [::logging::ellipsis_zeros \
			       [::logging::format_asc_bin $value]]

	if {$varname != ""} {
		# this BLE characteristic receives packets both for notifications of reads and writes, but also the real current value of the calibration setting
		if {[ifexists arr2(WriteKey)] == 0} {
			::bt::msg -INFO "ACK calibration: $varname value received: [array get arr2] ($_readable)"
			set ::de1($varname) $arr2(MeasuredVal)
		} else {
			::bt::msg -ERROR "ACK, no data, calibration:for $varname: [array get arr2] ($_readable) "
		}
	} else {
		::bt::msg -ERROR "unknown calibration data received: [array get arr2] ($_readable)"
	}

}

proc enable_de1_reconnect {} {
	::bt::msg -NOTICE "enable_de1_reconnect"
	set ::de1(disable_de1_reconnect) 1
	ble_connect_to_de1
}

proc disable_de1_reconnect {} {
	::bt::msg -NOTICE "disable_de1_reconnect"
	set ::de1(disable_de1_reconnect) 1
}

proc scanning_state_text {} {
	if {$::scanning == 1} {
		return [translate "Searching"]
	}

	if {$::currently_connecting_de1_handle != 0} {
		return [translate "Connecting"]
	}

	if {[expr {$::de1(connect_time) + 5}] > [clock seconds]} {
		return [translate "Connected"]
	}

	#return [translate "Tap to select"]
	if {[ifexists ::de1_needs_to_be_selected] == 1 || [ifexists ::peripheral_needs_to_be_selected] == 1} {
		return [translate "Tap to select"]
	}

	return [translate "Search"]
}

proc scanning_restart {} {
	::bt::msg -NOTICE scanning_restart
	if {$::scanning == 1} {
		return
	}
	if {$::android != 1} {

		# insert enough dummy devices to overfill the list, to test whether scroll bars are working
		set ::de1_device_list [list [dict create address "12:32:16:18:90" name "ble3" type "ble"] [dict create address "10.1.1.20" name "wifi1" type "wifi"] [dict create address "12:32:56:78:91" name "dummy_ble2" type "ble"] [dict create address "12:32:56:78:92" name "dummy_ble3" type "ble"] [dict create address "ttyS0" name "dummy_usb" type "usb"] [dict create address "192.168.0.1" name "dummy_wifi2" type "wifi"]]
		set ::peripheral_device_list [list [dict create address "51:32:56:78:90" name "ACAIAxxx" connectiontype "ble" devicetype "scale" devicefamily "acaiascale"] [dict create address "12:32:56:78:93" name "Dummy123" connectiontype "ble" devicetype "scale" devicefamily "unknown"] ]

		after 200 fill_peripheral_listbox
		after 400 fill_ble_listbox

		set ::scanning 1
		after 3000 { set scanning 0 }
		return
	} else {
		# only scan for a few seconds
		after 10000 { stop_scanner }
	}

	set ::scanning 1
	::bt::msg -NOTICE "Starting ble_scanner from ::scanning_restart"

	if {$::ble_scanner == ""} {
		set ::ble_scanner [ble scanner de1_ble_handler]
	}

	ble start $::ble_scanner
}
