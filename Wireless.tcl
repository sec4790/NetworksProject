#==================================
Define parameters
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
:q
