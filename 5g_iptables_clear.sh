#!/bin/bash

# Definiowanie typu łancucha (chain)
CHAIN="DOCKER-USER"

# Wylistowanie regul zawierajacych "br-" w interfejsie in lub out i usuniecie ich
iptables -S $CHAIN | grep -E ' -i br-|-o br-' | while read -r line; do
    rule=$(echo $line | sed "s/-A $CHAIN //")
    # Usunięcie reguly z iptables
    iptables -D $CHAIN $rule
    if [ $? -eq 0 ]; then
        echo "Regula usunieta: $rule"
    else
        echo "Nie udalo sie usunac reguly: $rule"
    fi
done

echo "Wszystkie reguly zawierajace 'br-' w $CHAIN zostaly usuniete."
