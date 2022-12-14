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
    pkg update
}

edit_rc()
{
    # a função sysrc é mais indicada para trabalhar com o /etc/rc.conf
    sysrc webcamd_enable="YES"
    sysrc moused_enable="YES"
    sysrc dbus_enable="YES"
    sysrc hald_enable="YES"
    sysrc sound_load="YES"
    sysrc snd_hda_load="YES"
}

vbox_rc()
{
    vboxguest_enable="YES"
    vboxservice_enable="YES"
}

edit_fstab()
{
    echo 'proc  /proc   procfs  rw  0   0' >> /etc/fstab
    mount -al
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
    pkg install -y x11/kde5 x11/sddm
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
    pkg_basic
    pkg install -y mate-desktop mate lightdm lightdm-gtk-greeter
    edit_rc
    edit_fstab
    sysrc lightdm_enable="YES"
}

gwindow_maker()
{
  echo "Starting Window Maker Installer"
  pkg_basic
  pkg install -y windowmaker gnustep gnome-themes-extra mixer.app wmpinboard wmnet wmcpuload wmtime   
  edit_rc
  edit_fstab
}

lumina()
{
    echo "Starting Lumina Installer"
    pkg_basic
    sysrc mixer_enable="YES"
    pkg install -y lumina
    dbus-uuidgen --ensure
}

i3()
{
    echo "Starting i3 Installer"
    pkg_basic
    pkg install -y i3 i3lock i3status
    pkg install dmenu
}

apps_menu()
{
    OPTION=0

    while [ $OPTION -ne 4 ]; do

        OPTION=$(dialog --backtitle "FreeBSD Desktop Installer" --title "Options" --menu "what would you like to install?" 15 40 20 1 "Desktop Enviroment" 2 "Apps" 3 "Drivers" 4 "Linuxulator" 5 "Quit" 2>&1 > /dev/tty )

        clear
        case $OPTION in
            1)
                menu
                break
                ;;
            2)
                apps_list
                break
                ;;
            3)
                drivers_list
                break
                ;;
            4)
                init_linuxulator
                break
                ;;
            *)
                break
                ;;
        esac
    done
    
}

apps_list()
{
    apps=$(dialog --stdout --checklist 'Which apps do you want to install?' 0 0 0 \
    firefox-esr '' OFF \
    chromium '' OFF \
    libreoffice '' OFF \
    kdenlive '' OFF \
    obs-studio '' OFF \
    inkscape '' OFF \
    vscode '' OFF \
    cawbird '' OFF \
    simplescreenrecorder '' OFF \
    thunderbird '' OFF \
    wifimgr '' OFF \
    winetricks '' OFF \
    gimp '' OFF \
    epdfview '' OFF \
    virtualbox-ose-additions '' OFF
    )

    if [ -z $apps ]
    then
        apps_menu
    else
        pkg install -y $apps
        if [[ $apps == *"virtualbox-ose-additions"* ]]; then
            vbox_rc
        fi
    fi
}

drivers_list()
{
    apps=$(dialog --stdout --checklist 'Which drivers do you want to install?' 0 0 0 \
    xf86-video-intel '' OFF \
    xf86-video-amdgpu '' OFF \
    xf86-video-vesa '' OFF \
    xf86-video-vmware '' OFF \
    drm-510-kmod '' OFF \
    vulkan-loader '' OFF \
    intel-em-kmod '' OFF \
    intel-ix-kmod '' OFF \
    intel-ixl-kmod '' OFF \
    realtek-re-kmod '' OFF \
    )

    if [ -ne $apps ]
    then
        apps_menu
    else
        pkg install -y $apps        
    fi
}


menu()
{
    CHOICE=0

    while [ $CHOICE -ne 8 ]; do

        CHOICE=$(dialog --backtitle "Desktop Enviroment Installer" --title "Select Enviroments" --menu "This is a script to make life easier for the novice user who wants to test FreeBSD as a Desktop" 15 40 20 1 "Gnome" 2 "Kde Plasma" 3 "Xfce" 4 "Mate" 5 "Window Maker" 6 "Lumina" 7 "i3" 8 "Quit" 2>&1 > /dev/tty)
        
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
                mate
                break
                ;;
            5)
                gwindow_maker
                for acthome in /home/*/; do 
                  echo 'exec wmaker' >> $acthome/.xinitrc
                done
                echo 'exec wmaker' >> /root/.xinitrc
                break
                ;;
            6)
                lumina
                break
                ;;
            7)  
                i3
                break
                ;;
        esac
    done
}

using_latest_repo    
apps_menu
