# Params
set opt(chan)		Channel;
set opt(mac)		Mac/802_3;
set opt(delay)		1ms;
set opt(numNodes)	60;
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

proc finish {} {
        global ns opt trfd namfd
        $ns flush-trace
        close $trfd
        close $namfd
        exec nam $opt(nam) &
        exit 0
}

proc gen-topology {} {
	global ns opt node

        set node(0) [$ns node]
	for {set i 1} {$i < $opt(numNodes)} {incr i} {
		set node($i) [$ns node]
		lappend nodelist $node($i)
	}
        $node(0) color Red
        $node(0) shape box

        #create links between the nodes
        $ns simplex-link $node(0) $node(1) 0.3Mb 100ms DropTail
        $ns simplex-link $node(1) $node(0) 0.3Mb 100ms DropTail
        set lan [$ns newLan $nodelist 0.5Mb 40ms LL Queue/DropTail MAC/Csma/Cd Channel]

        #Give node position
        $ns simplex-link-op $node(0) $node(1) orient right
        $ns simplex-link-op $node(1) $node(0) orient left

        #set queue size of link(n0-n1) to 20
        $ns queue-limit $node(0) $node(1) 20
}

proc gen-udp {} {
        global udp node ns

        #setup a UDP connection
        set udp [new Agent/UDP]
        $ns attach-agent $node(0) $udp
        set null [new Agent/Null]
        $ns attach-agent $node(3) $null
        $ns connect $udp $null
        $udp set fid_ 1
        return $udp
}

proc gen-cbr {} {
        global udp

        #setup a CBR over UDP connection
        set cbr [new Application/Traffic/CBR]
        $cbr attach-agent $udp
        $cbr set type_ CBR
        $cbr set packet_size_ 1000
        $cbr set rate_ 0.01Mb
        $cbr set random_ false
        return $cbr
}


set ns [new Simulator]

set trfd [gen-trace]
set namfd [gen-namtrace]

#define color for data flows
$ns color 1 Red

#create six nodes
gen-topology

set udp [gen-udp]
set cbr [gen-cbr]

#scheduling the events
$ns at 0.1 "$cbr start"
$ns at 125.5 "$cbr stop"
global ns
set time 0.1
set now [$ns now]
$ns at 0.1 "$cbr start"
 $ns at 10.0 "finish"
 $ns run
