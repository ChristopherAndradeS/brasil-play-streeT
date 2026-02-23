#!/bin/bash

# Garante que a lib do pawn seja encontrada
export LD_LIBRARY_PATH=./qawno:$LD_LIBRARY_PATH

# Compila a gamemode principal
./qawno/pawncc gamemodes/main.pwn -iqawno/include -Z+ "-;+" -d3 -ogamemodes/main.amx