#!/bin/bash

#--------------------------------------------------------------------------------------------------------------------------------
#                                       Trabalho 1
#                       Monitorização de interfaces de rede em bash
#
# Guião
#    O objectivo do trabalho é o desenvolvimento de um script em bash que apresenta estatísticas
# sobre a quantidade de dados transmitidos e recebidos nas interfaces de rede selecionadas, e sobre as
# respectivas taxas de transferência
# 
# Manuel Diaz       103645
# Tiago Carvalho    104142
#--------------------------------------------------------------------------------------------------------------------------------

# Inicialização de Arrays
declare -A optsOrd=() # Associative Array for options handling. Contains information about the arguments passed.
declare -a name
declare -A rx=()
declare -A tx=()
declare -A trate=()
declare -A rrate=()


# Inicilização de variáveis
nre="^[0-9]+|\.[0-9]?$" # nre : expressão regular para números.   
netifre='^[a-z]\w{1-14}$' # netifre : expressão regular para interfaces de rede.
i=0 #Usada para verificar a condição de -b, -k, -m
k=0 #Usada para verificar a condição de -t, -r, -T, -R
d=0
t=${@: -1}
#--------------------------------------------------------------------------------------------------------------------------------


# printf "%-15s %15s %15s %15s %15s\n" "NETIF" "TX" "RX" "TRATE" "RRATE"
#


function usage() {
    echo "Menu de Uso e Execução do Programa.     Ex -> netifstat.sh -c NETIF1 10"
    echo "    -c [NETIF] : Seleção das interfaces de rede, [NETIF], a visualizar através de uma expressão regular."
    echo "    -b         : Visualização das quantidades em bytes."
    echo "    -k         : Visualização das quantidades em kilobytes."
    echo "    -m         : Visualização das quantidades em megabytes."
    echo "    -p [n]     : Número, [n], de interfaces de redes a visualizar."
    echo "    -t         : Ordenação da tabela por TX (decrescente)."
    echo "    -r         : Ordenação da tabela por RX (decrescente)."
    echo "    -T         : Ordenação da tabela por TRATE (decrescente)."
    echo "    -R         : Ordenação da tabela por RRATE (decrescente)."
    echo "    -v         : Ordenação reversa (crescente)."
    echo "    -l [s]     : Loop de execução do programa a cada [s] segundos."
    echo "ALERTAS -> As opções -t,-r,-T,-R não podem ser utilizadas em simultâneo."
    echo "           O último argumento passado tem de o período de tempo desejado (segundos)."
}
function getTable() {
    printf "%-15s %15s %15s %15s %15s\n" "NETIF" "TX" "RX" "TRATE" "RRATE"
    for net in /sys/class/net/[[:alnum:]]*; do #check all the netifs available
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

#Option handling 
while getopts "c:bkmp:trTRvl:" option; do

    # Verificação do último argumento
    if [[ $# == 0 ]]; then
        echo "Necessário, pelo menos, o período de tempo desejado (segundos)."
        exit 1
    fi
    # Verificação do último argumento
    if [[ $t == $nre ]]; then
        echo "O último argumento deve ser um número."
        exit 1
    fi

    #Adicionar ao array optsOrd as opcoes passadas ao correr o programa.
    if [[ -z "$OPTARG" ]]; then
        optsOrd[$option]="blank" # Caso a opção não precise de argumento, passa blank para o array. Ex: -b -> blank
    else
        optsOrd[$option]=${OPTARG}  # Caso precisem de argumento, guarda o argumento no array.
    fi
    echo "$option -> ${optsOrd[$option]}"

    case $option in
    c) #Seleção das interfaces a visualizar através de uma expressão regular.
        str=${optsOrd[c]}
        if [[ $str == 'blank' || ${str:0:1} == "-" || $str =~ $netifre ]]; then
            echo "Error : A opção -c requer que se indique a interface de rede desejada. Ex -> netifstat -c NETIF1 10" >&2
            exit 1
        fi
        ;;
    p) #Seleção do número de interfaces de redes a visualizar.
        str=${optsOrd['p']}
        if [[ $str == 'blank' || ${str:0:1} == "-" || $str == ^$nre ]]; then
            echo "Error : A opção -p requer que se indique o número de redes a visualizar. Ex -> netifstat -p 2 10" >&2
            exit 1
        fi
        ;;
    l) #Seleção do intrevalo de tempo entre execuções do loop.
        str=${optsOrd[l]}
        if [[ $str == 'blank' || ${str:0:1} == "-" || $str == ^$nre ]]; then
            echo "Error : A opção -l requer que se indique o número segundos entre as execuções. Ex -> netifstat -l 2 10" >&2
            exit 1
        fi
        ;;
    r) #Ordenação reversa (crescente).
        ;;
    b | k | m ) #Verificar se
        if [[ $i = 1 ]]; then
            echo "Só é permitido o uso de uma das opções : -b, -k ou -m."
            usage
            exit 1
        fi
        ;;
    t | r | T | R) 
        if [[ $k = 1 ]]; then
            echo "Só é premitido o uso de uma das opções : -t, -r, -T ou -R."
            usage
            exit 1
        fi

        ;;
    v)
        ;;
    *) # Uso de argumentos inválidos
        echo "Uso de argumentos inválidos."
        usage
        exit 1
        ;;
    esac
done