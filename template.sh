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
declare -A optsOrd=() # Array for options handling. Contains information about the arguments passed.


n_re='^[0-9]+([.][0-9]+)?$' # n_re : expressão regular para números.
netif_re='^[a-z]\w{1,14}$' # n_re : expressão regular para interfaces de rede.

if [[ $# == 0 ]]; then
    echo "Necessário o período de tempo desejado (segundos)."
    usage
    exit 1
fi

function usage() {
    echo "ERRO AO USAR O PROGRAMA!"
    echo "  -c [NETIF] : Seleção das interfaces de rede, [NETIF], a visualizar através de uma expressão regular."
    echo "  -b         : Visualização das quantidades em bytes."
    echo "  -k         : Visualização das quantidades em kilobytes."
    echo "  -m         : Visualização das quantidades em megabytes."
    echo "  -p [n]     : Número, [n], de redes a visualizar."
    echo "  -t         : Ordenação da tabela por TX (decrescente)."
    echo "  -r         : Ordenação da tabela por RX (decrescente)."
    echo "  -T         : Ordenação da tabela por TRATE (decrescente)."
    echo "  -R         : Ordenação da tabela por RRATE (decrescente)."
    echo "  -v         : Ordenação reversa (crescente)."
    echo "  -l [s]     : Loop de execução do programa a cada [s] segundos."
    echo "ALERTAS -> As opções -t,-r,-T,-R não podem ser utilizadas em simultâneo."
    echo "           O último argumento passado tem de o período de tempo desejado (segundos)."
}

#Option handling 
while getopts "c:bkmp:trTTvl:" option; do
    #Adicionar ao array optsOrd as opcoes passadas ao correr o programa.
    if [[ -z "$OPTARG" ]]; then
        optsOrd[$option]="blank" # Caso não existam, fica 'blank'.
    else
        optsOrd[$option]=${OPTARG}  # Caso existam.
    fi

    case $option in
    c) #Seleção das interfaces a visualizar através de uma expressão regular.
        str=${argOpt['c']}
        if [[ $str == 'blank' || ${str:0:1} == "-" || $str =~ $re ]]; then
            echo "Argumento de '-c' não foi preenchido, foi introduzido argumento inválido ou chamou sem '-' atrás da opção passada." >&2
            usage
            exit 1
        fi
        ;;
    u) #Seleção de processos a visualizar através do nome do utilizador
        str=${argOpt['u']}
        if [[ $str == 'blank' || ${str:0:1} == "-" || $str =~ $re ]]; then
            echo "Argumento de '-u' não foi preenchido, foi introduzido argumento inválido ou chamou sem '-' atrás da opção passada." >&2
            usage
            usage exit 1
        fi
        ;;
    p) #Número de processos a visualizar
        if ! [[ ${argOpt['p']} =~ $re ]]; then
            echo "Argumento de '-p' tem de ser um número ou chamou sem '-' atrás da opção passada." >&2
            usage
            exit 1
        fi
        ;;
    r) #Ordenação reversa

        ;;
    m | t | d | w)

        if [[ $i = 1 ]]; then
            #Quando há mais que 1 argumento de ordenacao
            usage
            exit 1
        else
            #Se algum argumento for de ordenacao i=1
            i=1
        fi
        ;;

    *) #Passagem de argumentos inválidos
        usage
        exit 1
        ;;
    esac

done

## OK AGR FALTA REALMENTE FAZER COISAS, TUDO PARA CIMA FUNCIONA