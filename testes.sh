#!/bin/bash

declare -A optsOrd=()
declare -a name
declare -A rx=()
declare -A tx=()
declare -A trate=()
declare -A rrate=()
nre='^[0-9]+([.][0-9]+)?$'
netifre='^[a-z]\w{1-14}$'

while getopts "c:bkmp:trTTvl:" option; do
    #Adicionar ao array optsOrd as opcoes passadas ao correr o programa.
    if [[ -z "$OPTARG" ]]; then
        optsOrd[$option]="blank" # Caso não existam, fica 'blank'.
    else
        optsOrd[$option]=${OPTARG} # Caso existam.
    fi
done
t=${@: -1}
echo "${optsOrd[*]}"
function printTable() {
    #Imprimir o cabeçalho da tabela
    printf "%-15s %15s %15s %15s %15s\n" "NETIF" "TX" "RX" "TRATE" "RRATE"
    for net in /sys/class/net/[[:alnum:]]*; do 
        if [[ -r $net/statistics ]]; then
           f="$(basename -- $net)" #get netif and make a variable with its name
            rxb=$(cat $net/statistics/rx_bytes | grep -o -E '[0-9]+') #get rx in bytes
            txb=$(cat $net/statistics/tx_bytes | grep -o -E '[0-9]+') #get tx in bytes
            rrateb=$(bc <<< "scale=1;$rxb/$t") #get rrate in bytes
            trateb=$(bc <<< "scale=1;$txb/$t") #get trate in bytes
            name[$n]=$f #save netif name
            rx[$f]=$rxb #save rx value of that variable
            tx[$f]=$txb #save tx value of that variable
            rrate[$f]=$rrateb #save rrate value of that variable
            trate[$f]=$trateb #save trate value of that variable
            printf "%-15s %15s %15s %15s %15s\n" "$f" "${tx[$f]}" "${rx[$f]}" "${trate[$f]}" "${rrate[$f]}"
            let "n+=1" #increment
        fi
    done
}
printTable
