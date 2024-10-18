#!/bin/bash

# Script de mantenimiento para Gentoo

# Comprobar si el script se está ejecutando como root
if [ "$EUID" -ne 0 ]; then
  echo "Este script debe ejecutarse como root. Cambiando a root..."
  exec sudo "$0" "$@"
  exit 1
fi

# Función para mostrar mensajes
function mensaje {
    echo "===================================="
    echo "$1"
    echo "===================================="
}

# Actualiza el árbol de Portage
mensaje "Actualizando el árbol de Portage..."
emerge --sync

# Actualiza los paquetes del sistema
mensaje "Actualizando los paquetes del sistema..."
emerge -uDN @world

# Limpia paquetes no utilizados
mensaje "Limpiando paquetes no utilizados..."
emerge --ask --depclean

# Limpia la caché de Portage
mensaje "Limpiando la caché de Portage..."
eclean packages

# Opcional: Limpiar registros de log
mensaje "Limpiando registros antiguos..."
find /var/log -type f -exec truncate -s 0 {} \;

# Mensaje final
mensaje "Mantenimiento completo."
