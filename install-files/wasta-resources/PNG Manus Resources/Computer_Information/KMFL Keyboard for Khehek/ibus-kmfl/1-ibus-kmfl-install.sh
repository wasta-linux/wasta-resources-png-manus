#!/bin/bash

# ==============================================================================
# ibus/kmfl install for Ubuntu and Derivatives including Mint (12.04 and newer)
#
#   2012-10-30 aji: Initial script
#   2012-12-15 aji: cleanup comments, split into 2 scripts:
#                       -One for ibus-kmfl install (this script)
#                       -A second one for keyboard setup (in this same folder)
#   2013-01-01 aji: Merged back to single script, superuser block to set up
#                       superuser perms to run script (even from limited acct).
#   2013-03-29 aji: Added extra packages to 64-bit ibus so that won't have
#                       issues if installing 32-bit apps.
#                   Added 1.4.1-9 packages, make install based on Ubuntu version
#                       (precise or maya needs 1.4.1-7, newer can use 1.4.1-9)
#   2013-06-11 aji: Adjusting autostart to use standard Langauge Support method
#                       again.  A bug was fixed in Paratext so the manual ibus
#                       auto-start is not needed anymore.
#
# ==============================================================================

# ------------------------------------------------------------------------------
# Setup script to run with superuser permissions
# ------------------------------------------------------------------------------
if [ "$(whoami)" != "root" ]; then
    echo
    echo "This script needs to run with superuser permissions."
    echo "----------------------------------------------------"
    # below will return <blank> if user not in sudo group
    OUT=$(groups $(whoami) | grep "sudo")

    if [ "$OUT" ]; then
        # user has sudo permissions: use them to re-run the script
        echo
        echo "If prompted, enter the sudo password."
        #re-run script with sudo
        sudo bash $0
        LASTERRORLEVEL=$?
    else
        #user doesn't have sudo: limited user, so prompt for sudo user
        until [ "$OUT" ]; do
            echo
            echo "Current user doesn't have sudo permissions."
            echo
            read -p "Enter admin id (blank for root) to run this script:  " SUDO_ID

            # set SUDO_ID to root if not entered
            if [ "$SUDO_ID" ]; then
                OUT=$(groups ${SUDO_ID} | grep "sudo")
            else
                SUDO_ID="root"
                # manually assign $OUT to anything because we will use root!
                OUT="root"
            fi
        done

        # re-run script with $SUDO_ID 
        echo
        echo "Enter password for $SUDO_ID (need to enter twice)."
        su -l $SUDO_ID -c "sudo bash $0"
        LASTERRORLEVEL=$?

        # give 2nd chance if entered pwd wrong (su doesn't give 2nd chance)
        if [ $LASTERRORLEVEL == 1 ]; then
            su -l $SUDO_ID -c "sudo bash $0"
            LASTERRORLEVEL=$?
        fi
    fi

    echo
    read -p "FINISHED:  Press <ENTER> to exit..."
    exit $LASTERRORLEVEL
fi

# ------------------------------------------------------------------------------
# Initial prompt
# ------------------------------------------------------------------------------
echo
echo "=== ibus-kmfl Install ==================================================="
echo
echo "This script will locally install updated versions of ibus that work with"
echo "  all desktops tested including Unity, Cinnamon, Gnome-Shell, Xfce,"
echo "  and LXDE."
echo
echo "Default versions of ibus for Ubuntu have problems with using the ibus icon"
echo "  in the system tray to change keyboards."
echo
echo "This scipt will also install ibus-kmfl and SIL fonts."
echo
echo "NOTE: If ONLY Arabic is wanted (no Keyman keyboards are wanted), then"
echo "      don't use this script to set up ibus-kmfl but instead add Arabic"
echo "      through 'Keyboard Layout' preference panel in 'System Settings'."
echo
echo "Close this window if you do not want to run this script."
echo
read -p "Press <Enter> to continue..."

# Get directory script resides in so that can use later
DIR=$(dirname $0)

# ------------------------------------------------------------------------------
# Software Sources: Add SIL Repository and Key
# ------------------------------------------------------------------------------

# First: Remove line from file if already there (so as to not duplicate)
sed -i '\@deb http://packages.sil.org/ubuntu .* main@d' \
    /etc/apt/sources.list
# Next: add line to file
echo 'deb http://packages.sil.org/ubuntu precise main' | \
    tee -a /etc/apt/sources.list

# Install SIL Key
echo
echo 'Install SIL Key'
wget -q -O- http://packages.sil.org/sil.gpg | apt-key add -

# Update Sources
apt-get update

# ------------------------------------------------------------------------------
# Install updated ibus from Debian sid as Ubuntu hacked ibus to work
#    with Unity but it doesn't work right for other DEs (even Unity has issues)
# ------------------------------------------------------------------------------

# get machine architecture so will either install 64bit or 32bit
MACHINE_TYPE=$(uname -m)

if [ $MACHINE_TYPE == 'x86_64' ];
then
    echo
    echo "64 bit detected"
    
    if [[ "$(uname -v)" == *"precise"* || "$(lsb_release -sc)" == "maya" ]]
    then
        echo '64bit Ubuntu 12.04 Precise based distro'
        IBUS_FOLDER='ibussid64-4-1-7'
    else
        echo '64bit, but not Ubuntu 12.04 Precise based distro, assuming newer'
        IBUS_FOLDER='ibussid64-4-1-9'
    fi

else
    echo
    echo "32 bit detected"
    
    if [[ "$(uname -v)" == *"precise"* || "$(lsb_release -sc)" == "maya" ]]
    then
        echo "32bit Ubuntu 12.04 Precise based distro"
        IBUS_FOLDER='ibussid32-4-1-7'
    else
        echo "32bit, but not Ubuntu 12.04 Precise based distro, assuming newer"
        IBUS_FOLDER="ibussid32-4-1-9"
    fi
fi

echo
echo "ibus folder set to: $IBUS_FOLDER"

# Finally, install all .deb in folder (based on architecture)
dpkg -i $DIR/resources/$IBUS_FOLDER/*.deb

# errors will be encountered for 64 bit because need to install multiarch files.
if [ $? -ge 0 ];
then
    echo
    echo "i386 dependencies not installed by dpkg, so need to install with apt"
    apt-get --yes install -f
fi

# To have icon show in systemtray for Unity, need to whitelist
#   (Other DEs shouldn't need this, but doesn't cause a problem)
    # for root:
    sudo -u root gsettings set \
        desktop.unity.panel systray-whitelist "['all']"

    # for current logged on user:
    sudo -u $(logname) gsettings set \
    desktop.unity.panel systray-whitelist "['all']"

    # for default user template (copy from root):
    cp -rf $HOME/.config/dconf/ /etc/skel/.config/

# ------------------------------------------------------------------------------
# Install SIL Fonts
# ------------------------------------------------------------------------------

apt-get --yes install \
    ibus-kmfl \
    fonts-sil-andika \
    fonts-sil-andika-compact \
    fonts-sil-charissil \
    fonts-sil-doulossil \
    fonts-sil-gentiumplus \
    fonts-sil-gentiumpluscompact

# ------------------------------------------------------------------------------
# Make ibus the language input method of choice
# ------------------------------------------------------------------------------
# 2013-06-11: custom autostart for kmfl not needed anymore: Paratext fixed
#   to not have ibus conflict that caused the original problems with this.
#
#echo
#echo "Adding ibus/kmfl (Keyman) autostart."
#echo "    2012-11: Note BUG in Language Support so we don't use it to start ibus"
#echo
#
#echo -e \
#'[Desktop Entry]
#Type=Application
#Exec=ibus-daemon -xrd
#X-GNOME-Autostart-enabled=true
#Name=ibus/kmfl (Keyman)
#Comment=2012-11 Ubuntu 12.04 or Mint13: Do NOT use Language Support to start ibus!' | \
#tee /etc/xdg/autostart/ibus-daemon.desktop
#
# remove Language Support ibus autostart method from current and default user
#    # root
#    rm -rf /root/.xinput.d/
#
#    # logged in user
#    rm -rf /home/$(logname)/.xinput.d/
#
#    # default user
#    rm -rf /etc/skel/.xinput.d/
#

# removing old hack for ibus manual auto-start
rm -f /etc/xdg/autostart/ibus-daemon.desktop

echo
echo "Setting up ibus as keyboard input method in Language Support"
echo

# current user:
mkdir -p /home/$(logname)/.xinput.d
ln -sf /etc/X11/xinit/xinput.d/ibus /home/$(logname)/.xinput.d/en_US
ln -sf /etc/X11/xinit/xinput.d/ibus /home/$(logname)/.xinput.d/en_GB
chown -R $(logname):$(logname) /home/$(logname)/.xinput.d

# /etc/skel (template for new users)
mkdir -p /etc/skel/.xinput.d
ln -sf /etc/X11/xinit/xinput.d/ibus /etc/skel/.xinput.d/en_US
ln -sf /etc/X11/xinit/xinput.d/ibus /etc/skel/.xinput.d/en_GB

# root
mkdir -p /root/.xinput.d
ln -sf /etc/X11/xinit/xinput.d/ibus /root/.xinput.d/en_US
ln -sf /etc/X11/xinit/xinput.d/ibus /root/.xinput.d/en_GB

# ------------------------------------------------------------------------------
# reload ibus-daemon (if already running, if not, start it up!)
# ------------------------------------------------------------------------------
# do this from current logged on user, not from root (if used):
sudo -u $(logname) ibus-daemon -xrd

# ------------------------------------------------------------------------------
# Finished
# ------------------------------------------------------------------------------
exit 0
