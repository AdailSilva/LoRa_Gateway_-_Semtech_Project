#!/bin/bash
#set -eo pipefail
#_stopnow(){
#       test -f stopnow && "Stopping!" && rm stopnow && exit 0 || return 0
#}

begin=$(date +%s)
# Teste de SPI
#_stopnow
cd 'util_spi_stress' && ./util_spi_stress&
#PID=$!
elapsed_seconds=$(date +%s)
elapsed_seconds=$((elapsed_seconds-begin))
stop_time=10
echo begin
#echo $elapsed_seconds
#echo $stop_time
while [ $elapsed_seconds -lt $stop_time ]
        do
                elapsed_seconds=$(date +%s)
                elapsed_seconds=$((elapsed_seconds-begin))
#echo $elapsed_seconds
        done
#echo "out"
pkill -f util_spi_stress
echo 'Teste de SPI aprovado!'

#Teste de potência de transmissão
echo 'Iniciando teste de transmissão!'
begin=$(date +%s)
cd 'util_tx_continuous' && ./util_tx_continuous -f 902 -r 1257 --mod LORA --sf 12 --bw 500 &
count=0
while [ "$?" -ne 0 ] || [ $count -lt 3 ]; do
        echo 'Eeee lasquera!'
        ./util_tx_continuous -f 902 -r 1257 --mod LORA --sf 12 --bw 500 &
        count+=1
done
elapsed_seconds=$(date +%s)
elapsed_seconds=$((elapsed_seconds-begin))
stop_time=10
while [ $elapsed_seconds -lt $stop_time ]
        do
                elapsed_seconds=$(date +%s)
                elapsed_seconds=$((elapsed_seconds-begin))
        done
sudo pkill -f util_tx_continuous
echo 'Teste de potência de TX finalizado!'

#Teste de recepção
echo 'Stopping packet-forwarder service'
sudo service packet-forwarder stop
echo 'Reseting lora-gateway'
./reset_lgw.sh start
cd ..
ls
count=0
cd 'packet_forwarder/lora_pkt_fwd' && ./lora_pkt_fwd
while [ "$?" -ne 0 ] || [ "$count" -le 9 ]; do
        echo 'Subindo concentrador!'
        ./lora_pkt_fwd
        echo 'status:' $?
        echo 'counter:' $count
        count+=1
done
