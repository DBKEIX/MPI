#объект симулятор
set ns [new Simulator]
#файл вывода для nam
set nf [open out.nam w]
$ns namtrace-all $nf
#файл трассировки
set out [open out.tr w]
$ns trace-all $out

#число узлов получателей и источников
set N 25

#создание N источников
for {set i 0} {$i < $N} {incr i} {
set src_($i) [$ns node]
}

#создание N получателей
for {set i 0} {$i < $N} {incr i} {
set dst_($i) [$ns node]
}

#Создание узлов-роутеров
set node_(r1) [$ns node]
set node_(r2) [$ns node]

#соединение источников с 1м роутером
for {set i 0} {$i < $N} {incr i} {
$ns duplex-link $src_($i) $node_(r1) 100Mb 20ms DropTail
}

#соединение получателей с 2м роутером
for {set i 0} {$i < $N} {incr i} {
$ns duplex-link $node_(r2) $dst_($i) 100Mb 20ms DropTail
}
#соединение роутеров друг с другом
$ns simplex-link $node_(r1) $node_(r2) 20Mb 15ms RED
#лимит очереди
$ns queue-limit $node_(r1) $node_(r2) 300
#параметры RED
Queue/RED set tresh_ 75
Queue/RED set maxthresh_ 150
Queue/RED set  q_weight_ 0.002
Queue/RED set  linterm_ 10 


#обратное соединение роутеров
$ns simplex-link $node_(r2) $node_(r1) 15Mb 20ms DropTail 

#создание tcp соединения попарно между источниками и получателями
for {set i 0} {$i < $N} {incr i} {

set tcp($i) [$ns create-connection TCP/Reno $src_($i) TCPSink $dst_($i) 1]
#параметры TCP
$tcp($i) set window_ 32

set cbr($i) [new Application/Traffic/CBR]
$cbr($i) set packetSize_ 500
$cbr($i) attach-agent $tcp($i)

#подключение FTP поверх каждого TCP
set ftp($i) [$tcp($i) attach-source FTP]
$ftp($i) set class_ 1
}
#синий цвет
$ns color 1 Blue

#монитор размера окна
set windowVsTime [open WindowVsTime w]
set windowVsTime2 [open WindowVsTime2 w]
set qmon [$ns monitor-queue $src_(0) $node_(r1) [open qm.out w] 0.01];
[$ns link $src_(0) $node_(r1)] queue-sample-timeout;

#монитор очереди
set redq [[$ns link $node_(r1) $node_(r2)] queue]
set tchan_ [open all.q w]
$redq trace curq_
$redq trace ave_
$redq attach $tchan_

# Формирование файла с данными о размере окна TCP:
proc plotWindow {tcpSource file} {
global ns
set time 0.01
set now [$ns now]
set cwnd [$tcpSource set cwnd_]
puts $file "$now $cwnd"
$ns at [expr $now+$time] "plotWindow $tcpSource $file"
}

#at-событие запуска всех FTP
for {set i 0} {$i < $N} {incr i} {
$ns at 0.0 "$ftp($i) start"
}

proc finish {} {
global ns out nf tchan_
set awkCode {
{
if ($1 == "Q" && NF>2) {
print $2, $3 >> "temp.q";
set end $2
}
else if ($1 == "a" && NF>2)
print $2, $3 >> "temp.a";
}
}
set f [open temp.queue w]
puts $f "TitleText: red"
puts $f "Device: Postscript"
if { [info exists tchan_] } {
close $tchan_
}
exec rm -f temp.q temp.a
exec touch temp.a temp.q
exec awk $awkCode all.q 
#выполнение кода AWK
puts $f \"queue
exec cat temp.q >@ $f
puts $f \n\"ave_queue
exec cat temp.a >@ $f
close $f
    
$ns flush-trace
close $out
close $nf
exec nam out.nam &
exit 0
}

#запуск монитора окна
for {set i 0} {$i < $N} {incr i} {
$ns at 0.0 "plotWindow $tcp($i) $windowVsTime"
}

$ns at 0.0 "plotWindow $tcp(0) $windowVsTime2"
#время завершения
$ns at 20.0 "finish"
#команда на запуск
$ns run

