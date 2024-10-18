#!/bin/bash

# Función para listar discos y particiones
function listar_dispositivos() {
    echo "Discos y particiones disponibles:"
    lsblk -o NAME,LABEL,SIZE,TYPE,MOUNTPOINT
}

# Selección de partición raíz
function seleccionar_particion_raiz() {
    listar_dispositivos
    read -p "Introduce la partición raíz (ejemplo: sda3): " particion_raiz
    echo "Partición raíz seleccionada: /dev/$particion_raiz"
}

# Selección de partición boot
function seleccionar_particion_boot() {
    listar_dispositivos
    read -p "Introduce la partición /boot (ejemplo: sda1): " particion_boot
    echo "Partición boot seleccionada: /dev/$particion_boot"
}

# Selección de partición swap
function seleccionar_particion_swap() {
    listar_dispositivos
    read -p "Introduce la partición swap (ejemplo: sda2): " particion_swap
    echo "Partición swap seleccionada: /dev/$particion_swap"
}

# Montar particiones
function montar_particiones() {
    mkdir -p /mnt/gentoo
    mount /dev/$particion_raiz /mnt/gentoo
    mkdir -p /mnt/gentoo/boot
    mount /dev/$particion_boot /mnt/gentoo/boot
    swapon /dev/$particion_swap
    echo "Particiones montadas correctamente."
}

# Descargar y extraer Stage 3 Desktop Profile (OpenRC)
function descargar_stage3() {
    cd /mnt/gentoo
    echo "Descargando el Stage 3 Desktop Profile (OpenRC)..."
    wget http://distfiles.gentoo.org/releases/amd64/autobuilds/latest-stage3-amd64-desktop-openrc.txt
    STAGE3_URL=$(grep -o 'http.*\.tar\.xz' latest-stage3-amd64-desktop-openrc.txt)
    wget $STAGE3_URL
    echo "Extrayendo el archivo Stage 3..."
    tar xpvf stage3-*.tar.xz --xattrs-include='*.*' --numeric-owner
}

# Configurar make.conf
function configurar_make_conf() {
    echo "Configurando make.conf..."
    cat <<EOF > /mnt/gentoo/etc/portage/make.conf
ACCEPT_LICENSE="*"
USE="-systemd -qt -qt4 -qt5 -kde -gnome -gtk -gtk4 -wayland X elogind alsa nvidia opencl Xft pulseaudio"
LINGUAS="es es_AR"
L10N="es es-AR"
EMERGE_DEFAULT_OPTS="\${EMERGE_DEFAULT_OPTS} --getbinpkg --jobs=4 --load-average=4"
EOF
}

# Montar sistemas de archivos
function montar_sistemas_archivos() {
    mount --types proc /proc /mnt/gentoo/proc
    mount --rbind /sys /mnt/gentoo/sys
    mount --make-rslave /mnt/gentoo/sys
    mount --rbind /dev /mnt/gentoo/dev
    mount --bind /run /mnt/gentoo/run
    mount --make-rslave /mnt/gentoo/dev
    mount -t tmpfs tmpfs /mnt/gentoo/dev/shm
}

# Entrar en chroot
function entrar_chroot() {
    cp --dereference /etc/resolv.conf /mnt/gentoo/etc/
    chroot /mnt/gentoo /bin/bash -c "source /etc/profile && export PS1=\"(chroot) \${PS1}\""
}

# Instalar GRUB
function instalar_grub() {
    listar_dispositivos
    read -p "Selecciona el disco donde instalar GRUB (ejemplo: sda): " disco_grub
    echo "Instalando GRUB en /dev/$disco_grub..."
    grub-install /dev/$disco_grub
    grub-mkconfig -o /boot/grub/grub.cfg
}

# Función principal
function main() {
    echo "Automatización de instalación de Gentoo"

    seleccionar_particion_raiz
    seleccionar_particion_boot
    seleccionar_particion_swap
    montar_particiones
    descargar_stage3
    configurar_make_conf
    montar_sistemas_archivos

    echo "Preparado para chroot. ¿Quieres continuar en chroot? (s/n)"
    read continuar_chroot
    if [[ "$continuar_chroot" == "s" ]]; then
        entrar_chroot
    fi

    echo "¿Quieres instalar GRUB? (s/n)"
    read instalar_grub_opcion
    if [[ "$instalar_grub_opcion" == "s" ]]; then
        instalar_grub
    fi

    echo "Proceso completado."
}

# Ejecutar el script
main
