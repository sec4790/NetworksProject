#==================================
#Define parameters
#==================================
set val(chan)	Channel/WirelessChannel;
set val(netif)	Phy/WirelessPhy;
set val(prop)	Propagation/TwoRayGround;
set val(mac)	Mac/802_11;
set val(ifq)	Queue/DropTail/PriQueue;
set val(ll)		LL;
set val(ant)	Antenna/OmniAntenna;
set val(ifqlen)	50;
set val(nn)		2; 
set val(rp)		DSDV;


set f0 [open throu0.tr]
set f1 [open loss0.tr]
set f2 [open delay.tr]

#Initialize simulator
set ns [new Simulator]

#Initialize trace file
set tracefd [open wireless_trace.tr w]
$ns trace-all $tracefd

#initialize network animator
set namtrace [open wireless_trace.nam w]


#create topology object that keeps track of movements of mobilenodes
set topo [new Topography]
#create grid topology
$topo load_flatgrid 500 500

#Create God object (General Operations Director)
create-god $val(nn)

#Configure nodes using API and options from engr.iupui.edu
$ns_ node-config 		 -adhocRouting $val(rp) \
                         -llType $val(ll) \
                         -macType $val(mac) \
                         -ifqType $val(ifq) \
                         -ifqLen $val(ifqlen) \
                         -antType $val(ant) \
                         -propType $val(prop) \
                         -phyType $val(netif) \
                         -topoInstance $topo \
                         -channelType $val(chan) \
                         -agentTrace ON \
                         -routerTrace ON \
                         -macTrace OFF \
                         -movementTrace OFF;
						 
#Create mobile nodes
for {set i 0} {$i < $val(nn) } {incr i} {
               set node_($i) [$ns_ node ];
               $node_($i) random-motion 0       ;# disable random motion
       }  
	   
	   
#
# Provide initial (X,Y, for now Z=0) co-ordinates for node_(0) and node_(1)
#
$node_(0) set X_ 133
$node_(0) set Y_ 474
$node_(0) set Z_ 0.0

$node_(1) set X_ 333
$node_(1) set Y_ 474
$node_(1) set Z_ 0.0

#Produce simple node movements where node 1 moves towards node 0#
$ns_ at 50.0 "$node_(1) setdest 25.0 20.0 15.0"
$ns_ at 10.0 "$node_(0) setdest 20.0 18.0 1.0"
$ns_ at 100.0 "$node_(1) setdest 490.0 480.0 15.0"


#Set up connection and traffic flow between the two nodes#

set sink [new Agent/LossMonitor]
$ns_ attach-agent $node_(0) $sink


set agent [new Agent/UDP]
$agent set class_ 2
set sink [new Agent/TCPSink]
$ns_ attach-agent $node_(0) $agent
$ns_ attach-agent $node_(1) $sink
$ns_ connect $agent $sink
set cbr [new Application/Traffic/CBR]
$cbr attach-agent $agent
$ns_ at 10.0 "$cbr start" 






#
# Tell nodes when the simulation ends
#
for {set i 0} {$i < $val(nn) } {incr i} {
    $ns_ at 150.0 "$node_($i) reset";
}
$ns_ at 150.0 "stop"
$ns_ at 150.01 "puts \"NS EXITING...\" ; $ns_ halt"
proc stop {} {
    global ns_ tracefd
    $ns_ flush-trace
    close $tracefd

}

puts "Starting Simulation..."
$ns_ run
