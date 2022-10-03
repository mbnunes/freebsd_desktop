#!/bin/sh

using_latest_repo(){
  # Essa função troca os repositorios trimestrais do pkg pelos mais recentes
  mkdir -p /usr/local/etc/pkg/repos &&
  echo 'FreeBSD: {
  url: "pkg+http://pkg.FreeBSD.org/${ABI}/latest",
  mirror_type: "srv",
  signature_type: "fingerprints",
  fingerprints: "/usr/share/keys/pkg",
  enabled: yes
}' > /usr/local/etc/pkg/repos/FreeBSD.conf &&
  echo 'Katana: { 
    url: "pkg+https://raw.githubusercontent.com/fluxer/katana-freebsd/master", 
    mirror_type: "srv", 
    enabled: yes 
  }' >> /usr/local/etc/pkg/repos/Katana.conf &&
  pkg update -f
}

pkg_basic()
{
    pkg update
    pkg upgrade -y
    pkg install -y xorg
}

edit_rc()
{
    # a função sysrc é mais indicada para trabalhar com o /etc/rc.conf
    sysrc 'moused_enable="YES"'
    sysrc 'dbus_enable="YES"'
    sysrc 'hald_enable="YES"'
    sysrc 'sound_load="YES"'
    sysrc 'snd_hda_load="YES"'
}

edit_fstab()
{
    echo 'proc  /proc   procfs  rw  0   0'
}

gnome4()
{
    echo "Starting Gnome4 Installer"
    pkg_basic
    pkg install -y gnome-42_2 gnome-desktop-42.2 gdm-42.0_2
    edit_rc
    edit_fstab
    sysrc 'gnome_enable="YES"'
    sysrc 'gdm_enable="YES"'
}

kde_plasma()
{
    echo "Starting Kde Plasma Installer"
    pkg_basic
    pkg -y install x11/kde5 x11/sddm 
    edit_rc
    edit_fstab
    sysrc 'sddm_enable="YES"'
}

xfce()
{
    echo "Starting Xfce Installer"
    pkg_basic
    pkg install -y xfce lightdm lightdm-gtk-greeter 
    sysrc 'lightdm_enable="YES"'
}

mate()
{
    echo "Starting Mate Installer"
    pkg_basic
    pkg install -y mate-desktop mate slim slim-themes
    sysrc 'slim_enable="YES"'
}

window_maker()
{
  echo "Starting Window Maker Installer"
  pkg_basic
  pkg install -y gnustep windowmaker lightdm slim slim-themes
  sysrc 'slim_enable="YES"'
}

katana()
{
  echo "Starting Katana Installer"
  pkg_basic
  pkg install -y katana-workspace lightdm lightdm-gtk-greeter
  sysrc 'lightdm_enable="YES"'
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

while [ $CHOICE -ne 7 ]; do

    CHOICE=$(dialog 
      --backtitle "Desktop Enviroment Installer"   
      --title "Select Enviroments"  
      --menu "Este é um script com intuito de facilitar a vida do usuario iniciente que queira testar o FreeBSD como Desktop" 15 40 20 
        1 "Gnome"  
        2 "Kde Plasma"  
        3 "Xfce" 
        4 "Mate" 
        5 "Katana" 
        6 "Window Maker" 
        7 "Sair" 
        2>&1 > /dev/tty )

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
        4)
            mate
            ;;
        5)
            katana
            ;;
        6) 
            window_maker
            ;;
    esac
done
