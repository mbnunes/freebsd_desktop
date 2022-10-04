#!/bin/sh
# Developed by: Maurício Nunes               
# https://github.com/mbnunes/freebsd_desktop 
# Lisence: BSD v3



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
    pkg upgrade -y
    pkg install -y xorg
}

edit_rc()
{
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
    pkg install -y gnome gnome-desktop gdm
    edit_rc
    edit_fstab
    sysrc 'gnome_enable="YES"'
    sysrc 'gdm_enable="YES"'
}

kde_plasma()
{
    echo "Starting KDE Plasma Installer"
    pkg_basic
    pkg -y install x11/kde5 x11/sddm
    edit_rc
    edit_fstab
    sysrc 'sddm_enable="YES"'
}

xfce()
{
    echo "Starting XFCE Installer"
    pkg_basic
    pkg install -y xfce xfce4-goodies dbus lightdm lightdm-gtk-greeter 
    edit_rc
    edit_fstab
    sysrc 'lightdm_enable="YES"'
}

apps_menu()
{
    OPTION=0

    while [ $OPTION -ne 5 ]; do

        OPTION=$(dialog --backtitle "Desktop Enviroment Installer" --title "Apps" --menu "what would you like to install?" 15 40 20 1 "Apps" 2 "Drivers" 3 "Back" 2>&1 > /dev/tty )

        clear
        case $OPTION in
            1)
                apps_list
                break
                ;;
            2)
                drivers_list
                break
                ;;
            *)
                menu
                break
                ;;
        esac
    done
    
}

apps_list()
{
    apps=$(dialog --stdout --checklist 'Which apps do you want to install?' 0 0 0 \
    firefox ''  OFF \
    wifimgr ''  OFF \
    thunderbird ''  OFF \
    wine    ''  OFF \
    wine-gecko  ''  OFF \
    wine-mono   ''  OFF \
    libreoffice ''  OFF )

    if [ -z $apps ]
    then
        apps_menu
    else
        pkg install -y $apps
    fi
}

drivers_list()
{
    apps=$(dialog --stdout --checklist 'Which drivers do you want to install?' 0 0 0 \
    amdgpu '' OFF)

    if [ -z $apps ]
    then
        apps_menu
    else
        pkg install -y $apps
    fi
}


menu()
{
    using_latest_repo
    CHOICE=0

    while [ $CHOICE -ne 5 ]; do

        CHOICE=$(dialog --backtitle "Desktop Enviroment Installer" --title "Select Enviroments" --menu "This is a script to make life easier for the novice user who wants to test FreeBSD as a Desktop" 15 40 20 1 "Gnome" 2 "KDE Plasma" 3 "XFCE" 4 "Apps" 5 "Quit" 2>&1 > /dev/tty )
        
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
                apps_menu
                break
                ;;        
        esac
    done
}

menu