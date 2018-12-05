set ns [new Simulator]
set nf [open lab3.nam w]
set tf [open lab3.tr w]

$ns trace-all $tf
$ns namtrace-all $nf

set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]

$ns make-lan "$n0 $n1 $n2 $n3 $n4" 100Mb 100ms LL Queue/DropTail Mac/802_3
$ns duplex-link $n4 $n5 100Mb 100ms DropTail

set tcp0 [new Agent/TCP]
set tcp2 [new Agent/TCP]
$ns attach-agent $n0 $tcp0
$ns attach-agent $n2 $tcp2

set ftp0 [new Application/FTP]
$ftp0 set packetSize_ 500

$ftp0 set interval_ 0.0001
set ftp2 [new Application/FTP]
$ftp2 set packetSize_ 600
$ftp2 set interval_ 0.001
$ftp0 attach-agent $tcp0
$ftp2 attach-agent $tcp2

set file0 [open file1.tr w]
set file2 [open file2.tr w]
$tcp0 attach $file0
$tcp2 attach $file2
$tcp0 trace cwnd_
$tcp2 trace cwnd_

set sink3 [new Agent/TCPSink]
set sink5 [new Agent/TCPSink]
$ns attach-agent $n3 $sink3
$ns attach-agent $n5 $sink5
$ns connect $tcp0 $sink3
$ns connect $tcp2 $sink5

proc finish { } {
	global ns nf tf
	$ns flush-trace
	close $nf
	close $tf
	exec nam lab3.nam &
	exit 0
}

$ns at 0.1 "$ftp0 start"
$ns at 5 "$ftp0 stop"
$ns at 7 "$ftp0 start"
$ns at 0.2 "$ftp2 start"
$ns at 8 "$ftp2 stop"
$ns at 14 "$ftp0 stop"
$ns at 10 "$ftp2 start"
$ns at 15 "$ftp2 stop"
$ns at 16 "finish"
$ns run



