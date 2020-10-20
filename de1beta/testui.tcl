borg systemui 0x1e02
puts [winfo screenheight .]
after 1000 {puts [winfo screenheight .]}
vwait forever