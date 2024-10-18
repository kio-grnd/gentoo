# FLATPAK DBUS ERROR
#eval $(dbus-launch --sh-syntax)
#export DBUS_SESSION_BUS_ADDRESS
#export DBUS_SESSION_BUS_PID

# Iniciar el daemon de accesibilidad
/usr/libexec/at-spi-bus-launcher &


# Configuración del teclado
setxkbmap es  # Cambia "es" por el código de tu idioma si es diferente

# Iniciar xbindkeys
xbindkeys &

# Activar NumLock
numlockx on &  # Agrega esta línea para activar NumLock

# Para mostrar un cursor por defecto
xsetroot -cursor_name left_ptr &

# Para sonido con PipeWire
pamixer &

# nVIDIA fix-tearing
~/scripts/nvidia-fix-tearing.sh &

# Lanzar sxhkd para atajos de teclado
sxhkd &

# Iniciar bspwm
exec bspwm
