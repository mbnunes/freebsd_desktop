#!/bin/sh

using_latest_repo(){
  mkdir -p /usr/local/etc/pkg/repos &&
  echo 'FreeBSD: {
  url: "pkg+http://pkg.FreeBSD.org/${ABI}/latest",
  mirror_type: "srv",
  signature_type: "fingerprints",
  fingerprints: "/usr/share/keys/pkg",
  enabled: yes
}' > /usr/local/etc/pkg/repos/FreeBSD.conf &&
  pkg update -f
}

pkg_basic()
{
    pkg update
    pkg upgrade -y
    pkg install xorg
}

edit_rc()
{
    echo 'moused_enable="YES"' >> /etc/rc.conf
    echo 'dbus_enable="YES"' >> /etc/rc.conf
    echo 'hald_enable="YES"' >> /etc/rc.conf
    echo 'sound_load="YES"' >> /etc/rc.conf
    echo 'snd_hda_load="YES"' >> /etc/rc.conf
}

edit_fstab()
{
    echo 'proc  /proc   procfs  rw  0   0'
}

gnome4()
{
    echo "Starting Gnome4 Installer"
    pkg_basic
    pkg install gnome-42_2 gnome-desktop-42.2 gdm-42.0_2 -y
    edit_rc
    edit_fstab
    echo 'gnome_enable="YES"' >> /etc/rc.conf
    echo 'gdm_enable="YES"' >> /etc/rc.conf
}

kde_plasma()
{
    echo "Starting KDE Plasma Installer"
    pkg_basic
    pkg install x11/kde5 x11/sddm -y
    edit_rc
    edit_fstab
    echo 'sddm_enable="YES"' >> /etc/rc.conf

}

xfce()
{
    echo "Starting XFCE Installer"
    pkg_basic
    pkg install xfce slim slim-themes -y
    echo 'slim_enable="YES"' >> /etc/rc.conf
}

cria_xinit()
{
    declare -a USER_DIR
    USER_DIR=$(ls -d /home/*)
    for usuario in $USER_DIR
    do
        TEMP_USER=$(sed "s/\/home\///g" $usuario)
        echo $TEMP_USER
    done
}

using_latest_repo

CHOICE=0

while [ $CHOICE -ne 4 ]; do

    CHOICE=$(dialog --backtitle "Desktop Enviroment Installer" --title "Select Enviroments" --menu "Este é um script com intuito de facilitar a vida do usuario iniciente que queira testar o FreeBSD como Desktop" 15 40 20 1 "Gnome" 2 "KDE Plasma" 3 "XFCE" 4 "Sair" 2>&1 > /dev/tty )

    clear
    case $CHOICE in
        1)
            gnome4
            ;;
        2)
            kde_plasma
            ;;
        3)
            xfce
            ;;
    esac
done
