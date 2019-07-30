# Params
set opt(chan)		Channel;
set opt(mac)		Mac/802_3;
set opt(delay)		1ms;
set opt(numNodes)	5;
set opt(time)		100;
set opt(bw)             10Mb;
set opt(sz)             1000b;
set opt(ifq) 		Queue/DropTail;
set opt(ll)             LL;
set opt(chan)           Channel;
set opt(phys)           Phy/WiredPhy;
set opt(trace) 		out.tr;
set opt(nam)		out.nam;
set node(0)             0;

proc gen-trace {} {
	global ns opt

	set fd [open $opt(trace) w]
	$ns trace-all $fd
	return $fd
}

proc gen-namtrace {} {
	global ns opt
	
	set fd [open $opt(nam) w]
	$ns namtrace-all $fd
}

proc gen-topology {} {
	global ns opt node

	for {set i 0} {$i < $opt(numNodes)} {incr i} {
		set node($i) [$ns node]
		lappend nodelist $node($i)
	}
        set lan [$ns make-lan $nodelist $opt(bw) $opt(delay) $opt(ll) $opt(ifq) $opt(mac) $opt(chan) $opt(phys)]
}

proc gen-udp {} {
        global ns node

        set udp [new Agent/UDP]
        $ns attach-agent $node(0) $udp
        set null [new Agent/Null]
        $ns attach-agent $node(1) $null
        $ns connect $udp $null
        $udp set fid_ 2
        return $udp
}

proc gen-cbr {} {
        global udp opt
        
        set cbr [new Application/Traffic/CBR]
        $cbr attach-agent $udp
        $cbr set type_ CBR
        $cbr set packet_size_ $opt(sz)
        $cbr set rate_ 1mb
        $cbr set random_ false
        return $cbr
}

proc finish {} {
        global ns opt trfd namfd
        $ns flush-trace
        close $trfd
        close $namfd
        exec nam $opt(nam) &
        exit 0
}

# Main
set ns [new Simulator]
set trfd [gen-trace]
set namfd [gen-namtrace]

gen-topology

set udp [gen-udp]
set cbr [gen-cbr]

$ns at 0.1 "$cbr start"
$ns at 8.9 "$cbr stop"
$ns at 9.9 "finish"

$ns run
