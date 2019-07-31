# Params
set opt(mac)		Mac/802_3;
set opt(delay)		1ms;
set opt(numNodes)	60;
set opt(time)		100;
set opt(bigBw)          100Mb;
set opt(bw)             10Mb;
set opt(sz)             1000b;
set opt(cbrRate)        0.01Mb;
set opt(trace) 		out.tr;
set opt(nam)		out.nam;
set node(0)             0;
set cbr(0)              0;
set bnode(0)            0;


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

# Returns list of initialized nodes
proc init-nodes {} {
        global opt node ns

	for {set i 0} {$i < $opt(numNodes)} {incr i} {
		set node($i) [$ns node]
		lappend nodelist $node($i)
	}
        return $nodelist
}


proc gen-topology { r nodelist } {
	global ns opt node

        # Create link from router to lan
        $ns simplex-link $r $node(1) $opt(bigBw) $opt(delay) DropTail

        set lan [$ns newLan $nodelist $opt(bw) $opt(delay) LL Queue/DropTail $opt(mac) Channel]

        # Orient left to right
        $ns simplex-link-op $r $node(1) orient right
}

proc gen-udp { sender node } {
        global ns opt

        $sender color Red
        $sender shape box

        set udp [new Agent/UDP]
        $ns attach-agent $sender $udp
        set null [new Agent/Null]
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

# Returns a connection point between udp sources and lan network
proc gen-sender {} {
        global node opt cbr ns bnode

        # Create broadcasting nodes
        set bnode(0) [$ns node]
        set bnode(1) [$ns node]
        set bnode(2) [$ns node]
        set bnode(3) [$ns node]
        set bnode(4) [$ns node]

        set r [$ns node]

        # Create broadcast topology
        $ns simplex-link $bnode(0) $r $opt(bw) $opt(delay) DropTail
        $ns simplex-link $bnode(1) $r $opt(bw) $opt(delay) DropTail
        $ns simplex-link $bnode(2) $r $opt(bw) $opt(delay) DropTail
        $ns simplex-link $bnode(3) $r $opt(bw) $opt(delay) DropTail
        $ns simplex-link $bnode(4) $r $opt(bw) $opt(delay) DropTail


        $ns simplex-link-op $bnode(0) $r orient down
        $ns simplex-link-op $bnode(1) $r orient down-right
        $ns simplex-link-op $bnode(2) $r orient right
        $ns simplex-link-op $bnode(3) $r orient up-right
        $ns simplex-link-op $bnode(4) $r orient up

        set last [expr $opt(numNodes) - 1]
        set udp [gen-udp $bnode(0) $node($last)]
        set cbr(0) [gen-cbr $udp]
        set udp [gen-udp $bnode(1) $node($last)]
        set cbr(1) [gen-cbr $udp]
        set udp [gen-udp $bnode(2) $node($last)]
        set cbr(2) [gen-cbr $udp]
        set udp [gen-udp $bnode(3) $node($last)]
        set cbr(3) [gen-cbr $udp]
        set udp [gen-udp $bnode(4) $node($last)]
        set cbr(4) [gen-cbr $udp]

        return $r
}

set ns [new Simulator]

set trfd [gen-trace]
set namfd [gen-namtrace]

# Color data
$ns color 1 Red

set nodelist [init-nodes]
set router [gen-sender]
gen-topology $router $nodelist


# Divide timeline
set t(0) [expr $opt(time) * 5]
set t(1) [expr $t(0) * 2]
set t(2) [expr $t(0) * 3]
set t(3) [expr $t(0) * 4]
set t(4) [expr $t(0) * 5]

# Configure timeline & run
set time 0.1
set now [$ns now]
$ns at 0.1 "$cbr(0) start"
$ns at 0.1 "$cbr(1) start"
$ns at 0.1 "$cbr(2) start"
$ns at 0.1 "$cbr(3) start"
$ns at 0.1 "$cbr(4) start"
$ns at $t(1) "$bnode(1) off"
$ns at $t(2) "$bnode(2) off"
$ns at $t(3) "$bnode(3) off"
$ns at $t(4) "$bnode(4) off"
$ns at $opt(time) "finish"
$ns run
