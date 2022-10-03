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
  pkg update -f
}

pkg_basic()
{
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
    echo 'proc  /proc   procfs  rw  0   0' >> /etc/fstab
}

gnome4()
{
    echo "Starting Gnome4 Installer"
    pkg_basic
    pkg install -y gnome-42_2
    pkg install -y gnome-desktop-42.2
    pkg install -y gdm-42.0_2
    edit_rc
    edit_fstab
    sysrc 'gnome_enable="YES"'
    sysrc 'gdm_enable="YES"'
}

kde_plasma()
{
    echo "Starting KDE Plasma Installer"
    pkg_basic
    pkg -y install x11/kde5  
    pkg -y install x11/sddm
    edit_rc
    edit_fstab
    sysrc 'sddm_enable="YES"'
}

xfce()
{
    echo "Starting XFCE Installer"
    pkg_basic
    pkg install -y xfce 
    pkg install -y lightdm 
    pkg install -y lightdm-gtk-greeter 
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

apps_list()
{
    $apps=$(dialog --backtitle "Desktop Enviroment Installer - Applications" --stdout --checklist 'Quais aplicativos deseja instalar?' 0    0   0 \
    firefox ''  OFF \
    wifimgr ''  OFF \
    thunderbird ''  OFF \
    wine    ''  OFF \
    wine-gecko  ''  OFF \
    wine-mono   ''  OFF \
    libreoffice ''  OFF )
    pkg install -y $apps
}

using_latest_repo

CHOICE=0

while [ $CHOICE -ne 5 ]; do

    CHOICE=$(dialog --backtitle "Desktop Enviroment Installer" --title "Select Enviroments" --menu "Este é um script com intuito de facilitar a vida do usuario iniciente que queira testar o FreeBSD como Desktop" 15 40 20 1 "Gnome" 2 "KDE Plasma" 3 "XFCE" 4 "Sair" 2>&1 > /dev/tty )

    clear
    case $CHOICE in
        1)
            gnome4
            break
            ;;
        2)
            kde_plasma
            break
            ;;
        3)
            xfce
            break
            ;;
        4)
            apps_list
            break
            ;;
    esac
done
