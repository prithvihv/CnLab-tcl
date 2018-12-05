set ns [new Simulator]
set nf [open lab4.nam w]
set tf [open lab4.tr w]
set topo [new Topography]

$topo load_flatgrid 1000 1000
$ns trace-all $tf
$ns namtrace-all-wireless  $nf 1000 1000
# I AM CAPITAL PRITHVI
$ns node-config -adhocRouting DSDV \
-macType Mac/802_11 \
-channelType Channel/WirelessChannel \
-antType Antenna/OmniAntenna \
-propType Propagation/TwoRayGround \
-ifqType Queue/DropTail \
-ifqLen 50 \
-topoInstance $topo \
-agentTrace ON \
-llType LL \
-phyType Phy/WirelessPhy \
-routerTrace ON \

create-god 3

set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]

$n0 set X_ 50
$n0 set Y_ 50
$n0 set Z_ 0
$n1 set X_ 100
$n1 set Y_ 100
$n1 set Z_ 0
$n2 set X_ 600
$n2 set Y_ 600
$n2 set Z_ 0

$n0 label "tcp0"
$n1 label "sink1/tcp1"
$n2 label "sink2"

$ns at 0.1 "$n0 setdest 50 50 15"
$ns at 0.1 "$n1 setdest 100 100 25"
$ns at 0.1 "$n2 setdest 600 600 25"

set tcp0 [new Agent/TCP]
set tcp1 [new Agent/TCP]
set ftp0 [new Application/FTP]
set ftp1 [new Application/FTP]
set sink1 [new Agent/TCPSink]
set sink2 [new Agent/TCPSink]

$ns attach-agent $n0 $tcp0
$ftp0 attach-agent $tcp0
$ns attach-agent $n1 $tcp1
$ftp1 attach-agent $tcp1
$ns attach-agent $n1 $sink1
$ns attach-agent $n2 $sink2

$ns connect $tcp0 $sink1
$ns connect $tcp1 $sink2

proc finish  { } {
    global ns nf tf
    $ns flush-trace
    exec nam lab4.nam &
    exit 0
}
$ns at 5 "$ftp0 start"
$ns at 5 "$ftp1 start"
$ns at 100 "$n1 setdest 550 550 15"
$ns at 190 "$n1 setdest 70 70 15"
$ns at 250 "finish"
$ns run

