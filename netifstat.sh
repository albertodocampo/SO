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
declare -A optsOrd # Associative Array for options handling. Contains information about the arguments passed.
declare -A rx
declare -A rxb
declare -A rxb1
declare -A rxb2
declare -A tx
declare -A txb
declare -A txb1
declare -A txb2
declare -A trate
declare -A rrate
declare -A txtox
declare -A rxtox
declare -A printingOrd

# Inicilização de variáveis
nre="^[0-9]+|\.[0-9]?$" # Expressão regular usada para números.   
netifre='^[a-z]\w{1-14}$' # Expressão regular usada para interfaces de rede.
i=0 # Usada para verificar a condição de uso de apenas um dos -b, -k ou -m.
m=0 # Usada para verificar a condição de uso de apenas um dos -t, -r, -T ou -R.
d=0 # Usada para verificar a condição de -t, -r, -T, -R.
l=0 # Usada para trasnsportar valor do loop de -l.
p=-1 # Usada para trasnsportar o número de interfaces a visualizar de -c.
ctr=1 # Usada para calcular o valor de controlo dos argumentos.
k=1
reverse=""
t=${@: -1}
#--------------------------------------------------------------------------------------------------------------------------------

function usage() { # Menu de execução do programa.
    echo "Menu de Uso e Execução do Programa."
    echo "    -c [NETIF] : Seleção das interfaces de rede, [NETIF], a visualizar através de uma expressão regular."
    echo "    -b         : Visualização das quantidades em bytes."
    echo "    -k         : Visualização das quantidades em kilobytes."
    echo "    -m         : Visualização das quantidades em megabytes."
    echo "    -p [n]     : Número, [n], de interfaces de redes a visualizar."
    echo "    -t         : Ordenação da tabela por TX (decrescente)."
    echo "    -r         : Ordenação da tabela por RX (decrescente).".
    echo "    -T         : Ordenação da tabela por TRATE (decrescente)."
    echo "    -R         : Ordenação da tabela por RRATE (decrescente)."
    echo "    -v         : Ordenação reversa (crescente)."
    echo "    -l [s]     : Loop de execução do programa a cada [s] segundos."
    echo "ALERTAS -> As opções -t,-r,-T,-R não podem ser utilizadas em simultâneo."
    echo "           O último argumento passado tem de o período de tempo desejado (segundos)."
}
function getTable() { # Função principal do programa. Obtém os valores desejados, ordena-los e imprimi-los.
    n=0
    for net in /sys/class/net/[[:alnum:]]*; do #check all the netifs available
        if [[ -r $net/statistics ]]; then 
            f="$(basename -- $net)" # Passar $f com o nome da interface de rede.
            # Condição para apenas trabalhar com interfaces de rede que coincidam com a expressão regular passada pela opção -c.
            if [[ -v optsOrd[c] && ! $f =~ ${optsOrd[c]} ]]; then
                continue
            fi
            if [[ -z ${rxb1[$f]} ]]; then
                rxb1[$f]=$(cat $net/statistics/rx_bytes | grep -o -E '[0-9]+') # Obter do valor de RX1 em bytes.
            else
                rxb1[$f]=${rxb2[$f]}
            fi
            if [[ -z ${txb1[$f]} ]]; then
                txb1[$f]=$(cat $net/statistics/tx_bytes | grep -o -E '[0-9]+') # Obter do valor de TX1 em bytes.
            else
                txb1[$f]=${txb2[$f]}
            fi
        fi
    done
    sleep $t # Tempo de espera entre pedidos da quantidade de dados transmitidos e recebidos. Passado como último argumento.
    if [[ $l == 0 ]]; then
        printf "%-15s %15s %15s %15s %15s\n" "NETIF" "TX" "RX" "TRATE" "RRATE" # Imprimir o cabeçalho da tabela
    else
        printf "%-15s %15s %15s %15s %15s %15s %15s\n" "NETIF" "TX" "RX" "TRATE" "RRATE" "TXTOX" "RXTOX" # Imprimir o cabeçalho da tabela
    fi
    for net in /sys/class/net/[[:alnum:]]*; do # Verificar todas as interfaces de rede disponíveis
        if [[ -r $net/statistics ]]; then
            f="$(basename -- $net)" # Passar $f com o nome da interface de rede.
            # Condição para apenas trabalhar com interfaces de rede que coincidam com a expressão regular passada pela opção -c.
            if [[ -v optsOrd[c] && ! $f =~ ${optsOrd[c]} ]]; then
                continue
            fi
            rxb2[$f]=$(cat $net/statistics/rx_bytes | grep -o -E '[0-9]+') # Obter do valor de RX2 em bytes.
            txb2[$f]=$(cat $net/statistics/tx_bytes | grep -o -E '[0-9]+') # Obter do valor de TX2 em bytes.
            rxb=$((rxb2[$f] - rxb1[$f])) # Obter do valor de RX em bytes, subtraindo RX2 por RX1.
            txb=$((txb2[$f] - txb1[$f])) # Obter do valor de TX em bytes, subtraindo TX2 por TX1.
            rrateb=$(bc <<< "scale=1;$rxb/$t") # Obter do valor de RRATE em bytes.
            trateb=$(bc <<< "scale=1;$txb/$t") # Obter do valor de TRATE em bytes.
            mult=$((1024 ** d)) # Calculo usado para alterar a unidade desejada (Bytes, Kilobytes, Megabytes).
            rx[$f]=$(bc <<< "scale=1;$rxb/$mult") # Alterar RX para unidade desejada e salva-la no array.
            tx[$f]=$(bc <<< "scale=1;$txb/$mult") # Alterar TX para unidade desejada e salva-la no array.
            rrate[$f]=$(bc <<< "scale=1;$rrateb/$mult") # Alterar RRATE para unidade desejada e salva-la no array.
            trate[$f]=$(bc <<< "scale=1;$trateb/$mult") # Alterar TRATE para unidade desejada e salva-la no array.
            if [[ -z ${txtox[$f]} ]]; then
                txtox[$f]=0
            fi
            if [[ -z ${rxtox[$f]} ]]; then
                rxtox[$f]=0
            fi
            txtox[$f]=$(bc <<< "scale=1;${txtox[$f]}+${tx[$f]}")
            rxtox[$f]=$(bc <<< "scale=1;${rxtox[$f]}+${rx[$f]}")
            fi
    done
    for net in /sys/class/net/[[:alnum:]]*; do
        if [[ -r $net/statistics ]]; then
            f="$(basename -- $net)" # Passar $f com o nome da interface de rede.
            if [[ $n -lt $p || $p = -1 ]]; then # Condição para apenas serem vistos o número de interfaces passados pela opção -p.
                if [[ $l == 0 ]]; then
                    printf "%-15s %15s %15s %15s %15s\n" "$f" "${tx[$f]}" "${rx[$f]}" "${trate[$f]}" "${rrate[$f]}" # Imprimir os valores da tabela
                else
                    printf "%-15s %15s %15s %15s %15s %15s %15s\n" "$f" "${tx[$f]}" "${rx[$f]}" "${trate[$f]}" "${rrate[$f]}" "${txtox[$f]}" "${rxtox[$f]}" # Imprimir os valores da tabela
                fi
            fi
            let "n+=1"
        fi
    done | sort -k$k$reverse
}   
#Option handling 
while getopts "c:bkmp:trTRvl" option; do

    # Verificação do último argumento
    if [[ $# == 0 ]]; then
        echo "Necessário, pelo menos, o período de tempo desejado (segundos). Ex -> ./netifstat.sh 10"
        usage
        exit 1
    fi
    # Verificação do último argumento
    if [[ $t == $nre ]]; then
        usage # Menu de execução do programa.
        echo "O último argumento deve ser um número. Ex -> ./netifstat.sh 10"
        exit 1
    fi

    #Adicionar ao array optsOrd as opcoes passadas ao correr o programa.
    if [[ -z "$OPTARG" ]]; then
        optsOrd[$option]="blank" # Caso a opção não precise de argumento, passa blank para o array. Ex: -b -> blank
    else
        optsOrd[$option]=${OPTARG}  # Caso precisem de argumento, guarda o argumento no array.
    fi

    case $option in
    c) #Seleção das interfaces a visualizar através de uma expressão regular.
        c=${optsOrd[c]}
        if [[ $c == 'blank' || ${c:0:1} == "-" || $c =~ $netifre ]]; then
            echo "Error : A opção -c requer que se indique a interface de rede desejada. Ex -> netifstat -c NETIF1 10" >&2
            usage # Menu de execução do programa.
            exit 1
        fi
        let "ctr+=2" # Acrescentar 2 ao valor de controlo dos argumentos.
        ;;
    p) #Seleção do número de interfaces de redes a visualizar.
        p=${optsOrd[p]}
        if [[ $p == 'blank' || ${p:0:1} == "-" || $p == ^$nre ]]; then
            echo "Error : A opção -p requer que se indique o número de redes a visualizar. Ex -> netifstat -p 2 10" >&2
            usage # Menu de execução do programa.
            exit 1
        fi
        let "ctr+=2" # Acrescentar 2 ao valor de controlo dos argumentos.
        ;;
    l) #Seleção do intrevalo de tempo entre execuções do loop.
        l=1
        let "ctr+=1" # Acrescentar 2 ao valor de controlo dos argumentos.
        ;;
    v) #Ordenação reversa (crescente).
        reverse="r"
        let "ctr+=1" # Acrescentar 1 ao valor de controlo dos argumentos.
        ;;
    b | k | m ) #Verificar se
        if [[ $i = 1 ]]; then
            echo "Só é permitido o uso de uma das opções : -b, -k ou -m. Ex -> ./netifstat -b 10"
            usage # Menu de execução do programa.
            exit 1
        fi
        i=1
        if [[ ${optsOrd[k]} == "blank" ]]; then
            d=1;
        fi
        if [[ ${optsOrd[m]} == "blank" ]]; then
            d=2;
        fi
        let "ctr+=1" # Acrescentar 1 ao valor de controlo dos argumentos.
        ;;
    t | r | T | R) 
        reverse="r"
        if [[ $m = 1 ]]; then
            echo "Só é premitido o uso de uma das opções : -t, -r, -T ou -R. Ex -> ./netifstat -r 10"
            usage # Menu de execução do programa.
            exit 1
        fi
        if [[ $option == "t" ]]; then # Uso da opção -t.
            k=2 # Alterar a coluna 2 da impressão. Coluna dos valores de TX.
        fi
        if [[ $option == "r" ]]; then # Uso da opção -r.
            k=3 # Alterar a coluna 3 da impressão. Coluna dos valores de RX.
        fi
        if [[ $option == "T" ]]; then # Uso da opção -T.
            k=4 # Alterar a coluna 4 da impressão. Coluna dos valores de TRATE.
        fi
        if [[ $option == "R" ]]; then # Uso da opção -R.
            k=5 # Alterar a coluna 5 da impressão. Coluna dos valores de RRATE.
        fi
        let "ctr+=1" # Acrescentar 1 ao valor de controlo dos argumentos.
        ;;
    *) # Uso de argumentos inválidos.
        echo "Uso de argumentos inválidos."
        usage # Menu de execução do programa.
        exit 1
        ;;
    esac
done
# Verificar se o valor do controlo de argumentos é igual ao número de argumentos passados.
# Evitar casos em que o programa corre se forem usados argumentos do tipo -> ./netifstat -c 2
if ! [[ $# == $ctr ]]; then
    echo "Uso de argumentos inválidos."
    usage # Menu de execução do programa.
    exit 1
fi
# Execução da função getTable dependendo da opção -l (loop)
if [[ $l -gt 0 ]]; then
    while true; do # Loop sem quebras.
        getTable
        echo
    done
else
    getTable # Caso em que não se passa o argumento -l.
fi