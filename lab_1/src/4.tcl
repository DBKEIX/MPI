set ns [new Simulator]
$ns rtproto DV
set nf [open out.nam w]
$ns namtrace-all $nf
set f [open out.tr w]
$ns trace-all $f
proc finish {} {
global ns f nf
$ns flush-trace
close $f
close $nf
exec nam out.nam &
exit 0
}
set N 6
set M 5
for {set i 0} {$i < $N} {incr i} {
set n($i) [$ns node]
}
for {set i 0} {$i < $M} {incr i} {
$ns duplex-link $n($i) $n([expr ($i+1)%5]) 1Mb 10ms DropTail
}
$ns duplex-link $n(5) $n(1) 1Mb 10ms DropTail

set tcp0 [new Agent/TCP/Newreno]
$ns attach-agent $n(0) $tcp0

set ftp0 [new Application/FTP]
$ftp0 attach-agent $tcp0
$ftp0 set packetSize_ 500
$ftp0 set interval_ 0.005

set sink1 [new Agent/TCPSink/DelAck]
$ns attach-agent $n(5) $sink1
$ns connect $tcp0 $sink1
$ns at 0.5 "$ftp0 start"
$ns at 4.5 "$ftp0 stop"
$ns rtmodel-at 1.0 down $n(0) $n(1)
$ns rtmodel-at 2.0 up $n(0) $n(1)

$ns at 5.0 "finish"
$ns run
