#!/bin/bash

# Cambiar el fondo de pantalla cada minuto
while true; do
    # Cambia el fondo de pantalla usando imágenes de la carpeta especificada
    feh --randomize --bg-fill ~/.config/backgrounds/*

    # Esperar 60 segundos antes de cambiar nuevamente
    sleep 60
done

