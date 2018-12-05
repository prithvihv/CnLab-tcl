
set ns [new Simulator]
set nf [open lab1.nam w]
set tf [open lab1.tr w]

$ns trace-all $tf
$ns namtrace-all $nf

proc finish { } {
	global ns nf tf
	$ns flush-trace
	close $nf
	close $tf
	exec nam lab1.nam &
	exit 0
}

set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]

$ns duplex-link $n0 $n2 200Mb 1ms DropTail
$ns duplex-link $n1 $n2 100Mb 1ms DropTail
$ns duplex-link $n2 $n3 1Mb 10000ms DropTail

$ns queue-limit $n0 $n2 10
$ns queue-limit $n1 $n2 10

set upd0 [new Agent/UDP]
set upd1 [new Agent/UDP]
set upd2 [new Agent/UDP]

$ns attach-agent $n0 $upd0
$ns attach-agent $n1 $upd1
$ns attach-agent $n2 $upd2

set cbr0 [new Application/Traffic/CBR]
$cbr0 set interval_ 0.0005
$cbr0 set packetSize_ 5000
set cbr1 [new Application/Traffic/CBR]
set cbr2 [new Application/Traffic/CBR]

$cbr0 attach-agent $upd0
$cbr1 attach-agent $upd0
$cbr2 attach-agent $upd0
set null0 [new Agent/Null]
$ns attach-agent $n3 $null0

$ns connect $upd0 $null0
$ns connect $upd1 $null0

$ns at 0.1 "$cbr0 start"
$ns at 0.2 "$cbr1 start"
$ns at 1.0 "finish"
$ns run

