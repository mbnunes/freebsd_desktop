#!/bin/sh
# Developed by: Maurício Nunes 
# Colaborators: KitsuneSemCalda               
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
  echo 'Katana: { 
    url: "pkg+https://raw.githubusercontent.com/fluxer/katana-freebsd/master", 
    mirror_type: "srv", 
    enabled: yes 
  }' >> /usr/local/etc/pkg/repos/Katana.conf &&
  pkg update -f
  pkg upgrade -y
}

pkg_basic()
{
    pkg install -y xorg
}

edit_rc()
{
    # a função sysrc é mais indicada para trabalhar com o /etc/rc.conf
    sysrc moused_enable="YES"
    sysrc dbus_enable="YES"
    sysrc hald_enable="YES"
    sysrc sound_load="YES"
    sysrc snd_hda_load="YES"
}

edit_fstab()
{
    echo 'proc  /proc   procfs  rw  0   0' >> /etc/fstab
    
}

init_linuxulator(){
    service linux onestart
    mkdir -p /compat/linux/dev/shm /compat/linux/dev/fd /compat/linux/proc /compat/linux/sys
    echo 'devfs      /compat/linux/dev      devfs      rw,late                    0  0' >> /etc/fstab
    echo 'tmpfs      /compat/linux/dev/shm  tmpfs      rw,late,size=1g,mode=1777  0  0' >> /etc/fstab
    echo 'fdescfs    /compat/linux/dev/fd   fdescfs    rw,late,linrdlnk           0  0' >> /etc/fstab
    echo 'linprocfs  /compat/linux/proc     linprocfs  rw,late                    0  0' >> /etc/fstab 
    echo 'linsysfs   /compat/linux/sys      linsysfs   rw,late                    0  0' >> /etc/fstab
    mount -al
    sysrc linux_enable="YES"
    sysrc linux_mounts_enable="NO"
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
    pkg install -y xfce xfce4-goodies dbus lightdm lightdm-gtk-greeter 
    edit_rc
    edit_fstab
    sysrc lightdm_enable="YES"
}

mate()
{
    echo "Starting Mate Installer"
    pkg install -y mate-desktop mate lightdm-gtk-greeter
    edit_rc
    edit_fstab
    sysrc lightdm_enable="YES"
}

cria_xinit()
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
    intelgpu '' OFF \
    amdgpu '' OFF \
    vmware '' OFF 
    )

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

    while [ $CHOICE -ne 6]; do

        CHOICE=$(dialog --backtitle "Desktop Enviroment Installer" --title "Select Enviroments" --menu "This is a script to make life easier for the novice user who wants to test FreeBSD as a Desktop" 15 40 20 1 "Gnome" 2 "KDE Plasma" 3 "Xfce" 4 "Mate" 5 "Apps" 6 "Quit" 2>&1 > /dev/tty)
        
        clear
        case $CHOICE in
            1)
                gnome4
                init_linuxulator
                break
                ;;
            2)
                kde_plasma
                init_linuxulator
                break
                ;;
            3)
                xfce
                init_linuxulator
                break
                ;;

            4)  
                mate
                init_linuxulator
                break
                ;;

            5)
                apps_menu
                break
                ;;
        esac
    done
}

menu;
clear 
