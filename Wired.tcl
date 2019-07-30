# Params
set opt(mac)		Mac/802_3;
set opt(delay)		1ms;
set opt(numNodes)	60;
set opt(time)		100s;
set opt(bw)             10Mb;
set opt(sz)             1000b;
set opt(cbrRate)        0.01Mb;
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

        # Create link from router to lan
        $ns simplex-link $node(0) $node(1) $opt(bw) $opt(delay) DropTail
        $ns simplex-link $node(1) $node(0) $opt(bw) $opt(delay) DropTail
        set lan [$ns newLan $nodelist $opt(bw) $opt(delay) LL Queue/DropTail $opt(mac) Channel]

        # Orient left to right
        $ns simplex-link-op $node(0) $node(1) orient right
        $ns simplex-link-op $node(1) $node(0) orient left
}

proc gen-udp {} {
        global udp node ns opt

        set udp [new Agent/UDP]
        $ns attach-agent $node(0) $udp
        set null [new Agent/Null]
        set last [expr $opt(numNodes) - 1]
        $ns attach-agent $node($last) $null
        $ns connect $udp $null
        $udp set fid_ 1
        return $udp
}

proc gen-cbr {} {
        global udp opt

        #setup a CBR over UDP connection
        set cbr [new Application/Traffic/CBR]
        $cbr attach-agent $udp
        $cbr set type_ CBR
        $cbr set packet_size_ $opt(sz)
        $cbr set rate_ $opt(cbrRate)
        $cbr set random_ false
        return $cbr
}

set ns [new Simulator]

set trfd [gen-trace]
set namfd [gen-namtrace]

# Color data
$ns color 1 Red

gen-topology

set udp [gen-udp]
set cbr [gen-cbr]

# Configure timeline & run
set time 0.1
set now [$ns now]
$ns at 0.1 "$cbr start"
$ns at $opt(time) "finish"
$ns run
