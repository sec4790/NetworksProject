# Params
set opt(mac)		Mac/802_3;
set opt(delay)		10ms;
set opt(numNodes)	60.0;
set opt(time)		100;
set opt(bw)             1Mb;
set opt(sz)             1000b;
set opt(cbrRate)        0.01Mb;
set opt(trace) 		out.tr;
set opt(nam)		out.nam;

# Global state
set ns                  0;
set node(0)             0;
set sink(0)             0;
set udp(0)              0;
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

proc get-simulator {} {
        set ns [new Simulator]
        $ns color 1 Red
        return $ns        
}

# Returns stringify'd list on initialized nodes
proc init-nodes {} {
	global ns opt node sink udp

	for {set i 0} {$i < $opt(numNodes)} {incr i} {
		set node($i) [$ns node]
                set sink($i) [make-sink $node($i)]
                set udp($i) [make-udp $node($i)]
	}

        set last [expr int($opt(numNodes) - 1)]
        $ns duplex-link $node($last) $node(0) $opt(bw) $opt(delay) DropTail
	for {set i 0} {$i < $last} {incr i} {

                $ns duplex-link $node($i) $node([expr $i + 1]) $opt(bw) $opt(delay) DropTail
	}
}

# Returns sink handle
proc make-sink {node} {
        global ns 
        
        set sink [new Agent/Null] 
        $ns attach-agent $node $sink
        return $sink
}

# Returns udp handle
proc make-udp {node} {
        global ns

        set udp [new Agent/UDP]
        $udp set fid_ 1
        $ns attach-agent $node $udp
        return $udp
}

proc make-cbr {udp} {
        global ns opt

        set cbr [new Application/Traffic/CBR]
        $cbr attach-agent $udp
        $cbr set type_ CBR
        $cbr set packet_size_ $opt(sz)
        $cbr set rate_ $opt(cbrRate)
        $cbr set random_ false
        return $cbr
}

proc rand_range {lo hi} { return [expr int(rand()*($hi-$lo+1)) + $lo] }

proc connect-pair {numCbr} {
        global node opt udp sink ns cbr

        set lIndex $numCbr
        set rIndex [rand_range 0 [expr $opt(numNodes) -1]]

        if {$lIndex == $rIndex} {
                connect-pair $numCbr        
        } else {
                set sndr $udp($lIndex)
                set cbr($numCbr) [make-cbr $sndr] 
                $node($rIndex) color Red
                set rcvr $sink($rIndex)
                $ns connect $sndr $rcvr
        }
}
 
proc connect-pairs {n} {
	for {set i 0} {$i < $n} {incr i} {
                connect-pair $i
        }
}

proc gen-events {n} {
        global opt ns cbr

        $ns at 0.1 "$cbr(0) start"; # Doesn't like starting at 0
        set delta [expr $opt(time) / $n]
	for {set i 1} {$i < $n} {incr i} {
                set ts [expr $delta * $i]
                $ns at $ts "$cbr($i) start"
        }
}

set ns [get-simulator]

set trfd [gen-trace]
set namfd [gen-namtrace]

#create six nodes
set nodelist [init-nodes]

#create links between the nodes
connect-pairs $opt(numNodes)

#scheduling the events
gen-events $opt(numNodes)
global ns
set time 0.1
set now [$ns now]
$ns at $opt(time) "finish"
$ns run
