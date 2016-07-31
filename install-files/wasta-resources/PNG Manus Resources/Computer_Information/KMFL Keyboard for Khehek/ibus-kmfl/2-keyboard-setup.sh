#!/bin/bash

# ==============================================================================
# iBus Keyboard installation and setup (for KMFL and m17n keyboards)
#   
#   2012-12-16 aji: Initial script (split from 1-ibus-kmfl-install.sh script)
#   2013-01-01 aji: Merged back to single script, added superuser block.
#   2013-03-22 aji: Updated to handle any type of file for icon (instead of just
#       .bmp files.  TODO: make case-insensitive for file names.
#   2013-07-13 whm: Added the Khehek KHK.kmn keyboard, removed Arabic setup
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
echo "=== iBus Keyboard installation and setup ========================="
echo
echo "This script will install and set up KMFL keyboards for use with"
echo "  iBus.  It is assumed that ibus-kmfl was already installed by the"
echo "  '1-ibus-kmfl-setup.sh' script."
echo
echo "Close this window if you do not want to run this script."
echo
read -p "Press <Enter> to continue..."

# Get directory script resides in so that can use later
DIR=$(dirname $0)

# ------------------------------------------------------------------------------
# Set up desired keyman keyboards
# ------------------------------------------------------------------------------

IBUS_KMN='start'
MORE_KMN='Y'
ADD_KMN=''
while [ "[${MORE_KMN^^}]" = "[Y]" ]; do
    clear
    echo 'Enter code for Keyman Table you want to add to system.'
    echo '    For example, enter "KHK" (no quotes) to add KHK.kmn to system.'
    echo
    echo '    Keyman Table Choices:'
    echo
    echo '        KHK       BDH       BVI'
    echo
    echo '        DID       DIN       KRS'
    echo
    echo '        MIT       MM        MV'
    echo
    echo '        GE        TEX         '
    echo
    read -p 'Enter your table choice here:  ' ADD_KMN

    # Keyman files are UPPER.kmn, so ensure upper case
    # TODO aji 2013-03-22: try to fix so can have mixed case files but still case insensitive
    UPPER_ADD_KMN=${ADD_KMN^^}
    if [ $IBUS_KMN == 'start' ]; then
        IBUS_KMN="/usr/share/kmfl/"$UPPER_ADD_KMN".kmn"
    else
        IBUS_KMN=$IBUS_KMN',/usr/share/kmfl/'$UPPER_ADD_KMN'.kmn'
    fi

    # copy in files to kmfl directory
    cp $DIR/resources/tables/$UPPER_ADD_KMN.kmn /usr/share/kmfl/
    chmod 644 /usr/share/kmfl/$UPPER_ADD_KMN.kmn
    cp $DIR/resources/icons/$UPPER_ADD_KMN.* /usr/share/kmfl/icons/
    chmod 644 /usr/share/kmfl/icons/$UPPER_ADD_KMN*

    echo
    echo "=== MORE KEYMAN TABLES? ==="
    echo
    read -p 'Do you have more Keyman Tables to add (y/n*)?  ' MORE_KMN
    UPPER_MORE_KMN=${MORE_KMN^^}
done

#echo
#echo "=== SETUP FOR ARABIC? ==="
#echo
#read -p "Should we install Arabic in ibus (y/n*)?  " IBUS_ARABIC
#
#if [ "[${IBUS_ARABIC^^}]" = "[Y]" ];
#then
#    # ibus-m17n: needed for language options in ibus if use kmfl (Arabic)
#    # hunspell-ar: needed for Arabic spelling check (Libre Office)
#    apt-get --yes install ibus-m17n hunspell-ar
#    # set folder
#    IBUS_ARABIC=',m17n:ar:kbd'
#else
#    IBUS_ARABIC=''
#fi

# Load selected keyboards in ibus
    # for root:
    sudo -u root gconftool-2 --type=list --list-type=string -s \
        /desktop/ibus/general/preload_engines [$IBUS_KMN$IBUS_ARABIC]

    # for current logged on user, not for root:
    sudo -u $(logname) gconftool-2 --type=list --list-type=string -s \
        /desktop/ibus/general/preload_engines [$IBUS_KMN$IBUS_ARABIC]

    # for default user template (copy from root):
    mkdir -p /etc/skel/.gconf/desktop
    cp -rf /root/.gconf/desktop/ibus/ /etc/skel/.gconf/desktop/

# ------------------------------------------------------------------------------
# reload ibus-daemon (if already running, if not, start it up!)
# ------------------------------------------------------------------------------
# do this from current logged on user, not from root (if used):
sudo -u $(logname) ibus-daemon -xrd

# ------------------------------------------------------------------------------
# Finished
# ------------------------------------------------------------------------------
echo
echo "You may need to logout / login for correct keyboards to show"
echo "  under ibus icon in system tray."

exit 0
