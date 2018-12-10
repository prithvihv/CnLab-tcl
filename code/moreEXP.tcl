set ns [new Simulator]
set nf [open out.tr w]


set opt(title) zero;
set opt(stop) 100;#Stop time.
set opt(ecn) 0;
set opt(type) gsm;
# set opt(secondDelay) 55;
set opt(min) 30;
set opt(max) 0;
set opt(adp) 1;
set opt(flows) 0;
set opt(window) 30;
# set opt(web) 2;
set opt(wrap) 100;
set opt(srcTrace) is;
set opt(dstTrace) bs2;
set opt(gsmbuf) 10;
#default uplink bandwidth in bps
set bwDL(gsm) 9600
set bwUL(gsm) 9600
set propDL(gsm) .500
set buf(gsm) 10

$ns trace-all $nf
set nodes(bs1) [$ns node]
set nodes(bs2) [$ns node]
set nodes(ms)  [$ns node]
set nodes(is)  [$ns node]
set nodes(lp) [$ns node]

proc cell_topo { } {
    global ns nodes
    $ns duplex-link $nodes(lp) $nodes(bs1) 3Mbps 10ms DropTail
    $ns duplex-link $nodes(bs1) $nodes(ms) 1 1 RED
    $ns duplex-link $nodes(ms) $nodes(bs2) 1 1 RED
    $ns duplex-link $nodes(bs1) $nodes(is) 3Mbps 50ms DropTail
    puts "Cell topo"
}

proc set_link_params {t} {
    global ns nodes bwUL bwDL propDL buf
    $ns bandwidth $nodes(bs1) $nodes(ms) $bwDL($t) simplex
    $ns bandwidth $nodes(ms) $nodes(bs1) $bwUL($t) simplex
    $ns bandwidth $nodes(bs2) $nodes(ms) $bwDL($t) simplex
    $ns bandwidth $nodes(ms) $nodes(bs2) $bwUL($t) simplex
    $ns delay $nodes(bs1) $nodes(ms) $propDL($t) simplex
    $ns delay $nodes(ms) $nodes(bs1) $propDL($t) simplex
    $ns delay $nodes(bs2) $nodes(ms) $propDL($t) simplex
    $ns delay $nodes(ms) $nodes(bs2) $propDL($t) simplex
    $ns queue-limit $nodes(bs1) $nodes(ms) $buf($t)
    $ns queue-limit $nodes(ms) $nodes(bs1) $buf($t)
    $ns queue-limit $nodes(bs2) $nodes(ms) $buf($t)
    $ns queue-limit $nodes(ms) $nodes(bs2) $buf($t)
}

Queue/RED set summarystats_ true
Queue/DropTail set summarystats_ true
Queue/RED set adaptive_ $opt(adp)
Queue/RED set q_weight_ 0.0
Queue/RED set thresh_ $opt(min)
Queue/RED set maxthresh_ $opt(max)
Queue/DropTail set shrink_drops_ true
Agent/TCP set ecn_ $opt(ecn)
Agent/TCP set window_ $opt(window)
DelayLink set avoidReordering_ true
source web.tcl

# $ns deplay-interval
switch $opt(type) {
    gsm -
    gprs -
    utms {cell_topo}
}

set_link_params $opt(type)
$ns insert-delayer $nodes(ms) $nodes(bs1) [new Delayer]
$ns insert-delayer $nodes(bs1) $nodes(ms) [new Delayer]
$ns insert-delayer $nodes(ms) $nodes(bs2) [new Delayer]
$ns insert-delayer $nodes(bs2) $nodes(ms) [new Delayer]

set tcp1 [$ns create-connection TCP/Sack1 $nodes(is) TCPSink/Sack1 $nodes(lp) 0]
set ftp1 [[set tcp1] attach-app FTP]
$ns at 0.8 "[set ftp1] start"
proc stop {} {
    global nodes opt nf
    set wrap $opt(wrap)
    set sid [$nodes(is) id]
    set did [$nodes(bs2) id]
    set a "out.tr"
    set GETRC "../../../bin/getrc"
    set RAW2XG "../../../bin/raw2xg"
    exec $GETRC -s $sid -d $did -f 0 out.tr |\
    $RAW2XG -s 0.01 -m $wrap -r > plot.xgr
    exec $GETRC -s $did -d $sid -f 0 out.tr |\
    $RAW2XG -a -s 0.01 -m $wrap >> plot.xgr
    exec $GETRC -s $sid -d $did -f 1 out.tr |\
    $RAW2XG -s 0.01 -m $wrap -r >> plot.xgr
    exec $GETRC -s $did -d $sid -f 1 out.tr |\
    $RAW2XG -s 0.01 -m $wrap -a >> plot.xgr
    exec ./xg2gp.awk plot.xgr
    exec xgraph -x time -y packets plot.xgr &
    exit 0
}

$ns at 100 "stop"
$ns run
