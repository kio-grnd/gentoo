#!/bin/bash

# Cierra picom si está en ejecución
pkill picom

# Espera un segundo para asegurarse de que se haya cerrado
sleep 1

# Reinicia picom
picom &
