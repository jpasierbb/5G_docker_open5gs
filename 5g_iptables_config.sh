#!/bin/bash

# Pobieranie nazw dwoch najnowszych bridge
bridges=$(ls -lt /sys/class/net | grep -o 'br[^\ ]*' | sort -u | head -n 2)

# Konwersja wynikow na tablice
readarray -t bridge_array <<< "$bridges"

# Sprawdzenie czy mamy 2 bridge
if [ ${#bridge_array[@]} -ne 2 ]; then
    echo "Nie znaleziono wystarczajacej liczby bridge (potrzebne sa 2)."
    exit 1
fi

# Przypisanie nazw bridgow z listy
br1=${bridge_array[0]}
br2=${bridge_array[1]}

# Dodanie regul iptables
sudo iptables -I DOCKER-USER -i "$br1" -o "$br2" -j ACCEPT
sudo iptables -I DOCKER-USER -i "$br2" -o "$br1" -j ACCEPT

echo "Reguly iptables zostaly dodane pomyslnie."


