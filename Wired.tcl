# Params
set opt(mac)		Mac/802_3;
set opt(delay)		1ms;
set opt(numNodes)	5;
set opt(time)		100s;
set opt(bw)             10Mb;
set opt(sz)             1000b;
set opt(cbrRate)        0.01Mb;
set opt(trace) 		out.tr;
set opt(nam)		out.nam;
set cbr(0)              0;

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

# Returns stringify'd list on initialized nodes
proc init-nodes {} {
	global ns opt node

	for {set i 0} {$i < $opt(numNodes)} {incr i} {
		set node($i) [$ns node]
		lappend nodelist $node($i)
	}
        return $nodelist
}

proc gen-udp {sender node} {
        global ns opt

        set udp [new Agent/UDP]
        $ns attach-agent $sender $udp
        set null [new Agent/Null]
        set last [expr $opt(numNodes) - 1]
        $ns attach-agent $node $null
        $ns connect $udp $null
        $udp set fid_ 1
        return $udp
}

proc gen-cbr { udp } {
        global opt

        set cbr [new Application/Traffic/CBR]
        $cbr attach-agent $udp
        $cbr set type_ CBR
        $cbr set packet_size_ $opt(sz)
        $cbr set rate_ $opt(cbrRate)
        $cbr set random_ false
        return $cbr
}


proc gen-router-topology {} {
 global node opt cbr ns bnode

        # Create broadcasting nodes
        set bnode(0) [$ns node]
        set bnode(1) [$ns node]
        set bnode(2) [$ns node]
        set bnode(3) [$ns node]
        set bnode(4) [$ns node]

        set router [$ns node]

        # Create broadcast topology
        $ns simplex-link $bnode(0) $router $opt(bw) $opt(delay) DropTail
        $ns simplex-link $bnode(1) $router $opt(bw) $opt(delay) DropTail
        $ns simplex-link $bnode(2) $router $opt(bw) $opt(delay) DropTail
        $ns simplex-link $bnode(3) $router $opt(bw) $opt(delay) DropTail
        $ns simplex-link $bnode(4) $router $opt(bw) $opt(delay) DropTail


        $ns simplex-link-op $bnode(0) $router orient down
        $ns simplex-link-op $bnode(1) $router orient down-right
        $ns simplex-link-op $bnode(2) $router orient right
        $ns simplex-link-op $bnode(3) $router orient up-right
        $ns simplex-link-op $bnode(4) $router orient up

        set last [expr $opt(numNodes) - 1]
        set udp [gen-udp $router $node($last)]
        set cbr(0) [gen-cbr $udp]
        set udp [gen-udp $bnode(1) $node($last)]
        set cbr(1) [gen-cbr $udp]
        set udp [gen-udp $bnode(2) $node($last)]
        set cbr(2) [gen-cbr $udp]
        set udp [gen-udp $bnode(3) $node($last)]
        set cbr(3) [gen-cbr $udp]
        set udp [gen-udp $bnode(4) $node($last)]
        set cbr(4) [gen-cbr $udp]

        return $router
}

set ns [new Simulator]

set trfd [gen-trace]
set namfd [gen-namtrace]

#define color for data flows
$ns color 1 Red
#create six nodes
set nodelist [init-nodes]
set router [gen-router-topology]

$router color Red
$router shape circle

#create links between the nodes
$ns duplex-link $router $node(0) 2Mb 10ms DropTail
set lan [$ns newLan $nodelist 0.5Mb 40ms LL Queue/DropTail MAC/Csma/Cd Channel]

#Give node position
$ns duplex-link-op $router $node(0) orient right


#scheduling the events
$ns at 0.1 "$cbr(0) start"
$ns at 10.0 "$cbr(0) stop"
global ns
set time 0.1
set now [$ns now]
$ns at 10.0 "finish"
$ns run
 
