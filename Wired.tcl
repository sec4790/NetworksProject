####Simple wired script#####

set val(chan)		Channel;
set val(mac)		Mac/802_3;
set val(delay)		1ms;
set val(numNodes)	60;
set val(time)		100;

#Create a simulator object
set ns [new Simulator]

#open the trace file
set nf [open out.tr w]
#nf is file handler to handle trace file
$ns trace-all $nf

#Open the output files
set f0
set f1
set f2


##Create topology###
set num $val(numNodes)
for {set i 0} {$i < $num} {incr i} {
	set node($i) [$ns node]
}

#connect nodes using duplex link ####
##use duplex links to connect##


##attach agents/UDPs####


####record the process#####

###create traffic between nodes####
###use CBR Constant Bit Rate

##finish procedure
proc finish {} {
	global f0 f1 f2
	#close output files
	close $f0
	close $f1
	close $f2

	#call xgraph to display the results
	#of the original trace file names like the ones below
	exec xgraph out0.tr out1.tr out2.tr -geometry 800x400 &
	exit 0
}


