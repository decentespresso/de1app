namespace eval ::hds_sleep {
	variable handle 0
	variable address ""
	variable subscribed 0
	variable major -1
	variable probe ""
	variable wantsSleep 0
	variable exitRequired 0
	variable session 0
	variable generation 0
	variable phase idle
	variable attempt 0
	variable timer ""
	variable wakeLinks 0
	variable statusWrite ""
	variable writeAckTimeout 5100
	variable statusTimeout 1500
}

proc ::hds_sleep::active {link} {
	variable handle
	expr {$link ne "0" && $link eq $handle && [info exists ::de1(scale_device_handle)]
		&& $link eq $::de1(scale_device_handle) && $::settings(scale_type) eq "decentscale"}
}

proc ::hds_sleep::resetPhase {} {
	variable timer
	variable generation
	variable attempt
	variable phase
	after cancel $timer
	set timer ""
	incr generation
	set attempt 0
	set phase idle
}

proc ::hds_sleep::connected {link peer} {
	variable handle
	variable address
	variable subscribed
	variable major
	variable probe
	variable wantsSleep
	variable exitRequired
	variable session
	variable wakeLinks
	set peer [string toupper $peer]
	if {$peer ne $address || $peer eq ""} {
		set wantsSleep 0
		set exitRequired 0
		set wakeLinks 0
	}
	resetPhase
	incr session
	set address $peer
	set handle $link
	set subscribed 0
	set major -1
	set probe ""
}

proc ::hds_sleep::subscribed {link} {
	variable subscribed
	variable wantsSleep
	variable exitRequired
	if {![active $link]} {return 0}
	if {$subscribed} {return $exitRequired}
	set subscribed 1
	if {!$exitRequired} {return 0}
	if {$wantsSleep} {
		queueEnter
	} else {
		wakeOnLink
	}
	return 1
}

proc ::hds_sleep::isQuiet {link} {
	variable exitRequired
	expr {$exitRequired && [active $link]}
}

proc ::hds_sleep::displayGuard {link} {
	variable generation
	if {![active $link]} {return ""}
	return [list ::hds_sleep::allowDisplayOn $link $generation]
}

proc ::hds_sleep::allowDisplayOn {link epoch} {
	variable generation
	variable wantsSleep
	variable exitRequired
	expr {[active $link] && $epoch == $generation && !$exitRequired
		&& !($wantsSleep && [supportsSoftSleep])}
}

proc ::hds_sleep::supportsSoftSleep {} {
	variable major
	variable probe
	expr {$major >= 3 && $probe eq "accepted"}
}

proc ::hds_sleep::setIntent {sleeping} {
	variable address
	variable handle
	variable subscribed
	variable wantsSleep
	variable exitRequired
	variable phase
	variable wakeLinks
	if {$address eq "" || $address ne [string toupper $::settings(scale_bluetooth_address)]} {return 0}
	if {$sleeping && $::settings(keep_scale_on) != 1} {return 0}
	if {$sleeping} {
		if {$wantsSleep && $phase in {enterQueued enterAck asleep fallback}} {return 1}
		if {!$exitRequired && ![supportsSoftSleep]} {
			set wantsSleep 1
			return 0
		}
		resetPhase
		set wantsSleep 1
		if {$subscribed && [active $handle]} {queueEnter}
		return 1
	}
	if {!$exitRequired} {
		if {$phase eq "awakeConfirmed" && [active $handle]} {return 1}
		if {$wantsSleep} {resetPhase}
		set wantsSleep 0
		return 0
	}
	if {!$wantsSleep} {return 1}
	resetPhase
	set wantsSleep 0
	set wakeLinks 0
	if {$subscribed && [active $handle]} {wakeOnLink}
	return 1
}

proc ::hds_sleep::displayOnPacket {} {
	set units [format %02d [expr {$::settings(enable_fluid_ounces) == 1}]]
	decent_scale_make_command 0A 01 01 $units 01
}

proc ::hds_sleep::packet {kind} {
	switch -- $kind {
		probe {decent_scale_make_command 22 00}
		enter {decent_scale_make_command 0A 04 01}
		exit {decent_scale_make_command 0A 04 00}
		status {displayOnPacket}
		fallback {decent_scale_make_command 0A 00 00}
	}
}

proc ::hds_sleep::send {kind} {
	variable handle
	variable subscribed
	variable session
	variable generation
	variable attempt
	if {!$subscribed || ![active $handle]} {return}
	set service $::de1(suuid_decentscale)
	set characteristic $::de1(cuuid_decentscale_write)
	if {![info exists ::sinstance($service)] || ![info exists ::cinstance($characteristic)]} {return}
	set payload [packet $kind]
	set cmd [list ble write $handle $service $::sinstance($service) $characteristic $::cinstance($characteristic) $payload]
	userdata_append "SCALE: HDS $kind" $cmd 0 [list ::hds_sleep::shouldDispatch $handle $session $generation $attempt $kind $payload]
}

proc ::hds_sleep::queueEnter {} {
	variable phase
	set phase enterQueued
	send enter
}

proc ::hds_sleep::wakeOnLink {} {
	variable phase
	variable wakeLinks
	if {$wakeLinks >= 2} {
		set phase unconfirmed
		return
	}
	incr wakeLinks
	queueExit
}

proc ::hds_sleep::queueExit {} {
	variable phase
	variable attempt
	incr attempt
	set phase exitQueued
	send exit
}

proc ::hds_sleep::armTimeout {delay} {
	variable timer
	variable handle
	variable generation
	variable attempt
	variable phase
	after cancel $timer
	set timer [after $delay [list ::hds_sleep::timeout $handle $generation $attempt $phase]]
}

proc ::hds_sleep::shouldDispatch {link connection epoch try kind payload} {
	variable session
	variable generation
	variable attempt
	variable subscribed
	variable probe
	variable phase
	variable wantsSleep
	variable exitRequired
	variable statusWrite
	variable writeAckTimeout
	if {![active $link] || !$subscribed || $connection != $session} {return 0}
	if {$kind eq "probe"} {
		if {$probe ne "queued"} {return 0}
		set probe sent
		return 1
	}
	if {$epoch != $generation || $try != $attempt} {return 0}
	switch -- $kind {
		enter {
			if {!$wantsSleep || $phase ne "enterQueued"} {return 0}
			set phase enterAck
			set exitRequired 1
			::device::scale::invalidate_hds_readiness $link
			armTimeout $writeAckTimeout
		}
		exit {
			if {$wantsSleep || $phase ne "exitQueued"} {return 0}
			set phase exitAck
			armTimeout $writeAckTimeout
		}
		status {
			if {$wantsSleep || $phase ne "statusQueued"} {return 0}
			set statusWrite $payload
			set phase statusAck
			armTimeout $writeAckTimeout
		}
		fallback {
			if {!$wantsSleep || $phase ne "fallback"} {return 0}
		}
	}
	return 1
}

proc ::hds_sleep::writeAck {link payload} {
	variable wantsSleep
	variable phase
	variable timer
	variable statusWrite
	variable statusTimeout
	if {![active $link]} {return}
	if {$wantsSleep && $phase eq "enterAck" && $payload eq [packet enter]} {
		after cancel $timer
		set timer ""
		set phase asleep
	} elseif {!$wantsSleep && $phase eq "exitAck" && $payload eq [packet exit]} {
		after cancel $timer
		set timer ""
		set phase statusQueued
		send status
	} elseif {!$wantsSleep && $phase eq "statusAck" && $payload eq $statusWrite} {
		set phase statusFrame
		armTimeout $statusTimeout
	}
}

proc ::hds_sleep::notification {link payload} {
	variable subscribed
	variable probe
	variable major
	variable phase
	variable wantsSleep
	variable exitRequired
	variable timer
	if {![active $link] || !$subscribed || [string length $payload] != 7} {return}
	binary scan $payload cu* octets
	lassign $octets model opcode high low battery version check
	if {$model != 0x03} {return}
	if {$opcode == 0x22} {
		if {$probe ne "sent" || $battery != 0 || $version != 0 || ($model ^ $opcode ^ $high ^ $low) != $check} {return}
		set probe accepted
		if {$wantsSleep && !$exitRequired && [supportsSoftSleep]} {queueEnter}
	} elseif {$opcode == 0x0A} {
		set tens [expr {$version >> 4}]
		set units [expr {$version & 0x0F}]
		if {$tens > 9 || $units > 9} {return}
		set candidate [expr {$tens * 10 + $units}]
		if {$candidate < 3 || $candidate > 30 || ($battery > 100 && $battery != 0xFF)} {return}
		set major $candidate
		if {!$wantsSleep && $phase in {statusAck statusFrame}} {
			after cancel $timer
			set timer ""
			set exitRequired 0
			set phase awakeConfirmed
		}
		if {$probe eq ""} {
			set probe queued
			send probe
		}
	}
}

proc ::hds_sleep::timeout {link epoch try stage} {
	variable generation
	variable attempt
	variable phase
	variable wantsSleep
	variable wakeLinks
	variable timer
	if {![active $link] || $epoch != $generation || $try != $attempt || $stage ne $phase} {return}
	after cancel $timer
	set timer ""
	if {$wantsSleep && $phase eq "enterAck"} {
		set phase fallback
		send fallback
	} elseif {!$wantsSleep && $phase eq "retryWait"} {
		queueExit
	} elseif {!$wantsSleep && $phase in {exitAck statusAck statusFrame}} {
		if {$attempt < 2} {
			set phase retryWait
			armTimeout 200
		} else {
			set phase unconfirmed
			if {$wakeLinks == 1} {
				::bt::msg -WARNING "HDS SoftSleep exit was not confirmed; reconnecting scale once"
				scale_disconnect_handler $link
			} else {
				::bt::msg -WARNING "HDS SoftSleep exit was not confirmed after reconnect"
			}
		}
	}
}
