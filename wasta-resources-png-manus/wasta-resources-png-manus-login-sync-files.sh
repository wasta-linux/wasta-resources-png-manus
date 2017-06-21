#!/bin/bash

# ==============================================================================
# wasta-resources-png-manus-postinst.sh
#
#   This script is installed by the debian/install script as root.
#   It is copied to the following system location:
#   /usr/share/wasta-resources-png-manus/wasta-resources-png-manus-login-sync-files.sh 
#   when the wasta-resources-png-manus package is installed, and gets listed in the
#   Startup Applications applet, so that it runs automatically at each user login (after
#   a 15 second delay).
#   It can be manually re-run, but is only intended to be run at package installation.  
#
#   2016-07-25 whm: initial script
#                   Copies resource docs from /usr/share/wasta-resources-png-manus
#                   to user's home dir to make it easier for user to find and/or 
#                   edit selected resource documents/files.
#                   Uses the rsync --update option for copying to skip any files
#                   for which the destination file already exists and has a date 
#                   later than the source file.
#   2017-06-21 whm: Tweaks of the script to get it to run in non-simulation mode. 
#
# ==============================================================================

# ------------------------------------------------------------------------------
# Check to ensure running as root
# ------------------------------------------------------------------------------
#   No fancy "double click" here because normal user should never need to run
#if [ $(id -u) -ne 0 ]
#then
#	echo
#	echo "You must run this script with sudo." >&2
#	echo "Exiting...."
#	sleep 5s
#	exit 1
#fi

# ------------------------------------------------------------------------------
# Initial Setup
# ------------------------------------------------------------------------------

echo
echo "*** Beginning wasta-resources-png-manus-login-sync-files.sh"
echo

# ------------------------------------------------------------------------------
# Copy/Sync resources from /usr/share/wasta-resources-png-manus to user's Home dir
# ------------------------------------------------------------------------------
echo
echo "*** Copying resources to user's Home directory"
# Note: Calling logname and the environment's $USER return root during installation of packages
# but at login, $USER should return the actual user, for example bill in my case.
user=$USER
homeDir="/home/$user"
echo "The Home Directory of user: is $homeDir"
echo "The user variable is $user"

#echo "Dry Run calling (-n option) of rsync..."
rsync -vr --update "/usr/share/wasta-resources/PNG Manus Resources/" "$homeDir/Documents"
rsync -vr --update "/usr/share/wasta-resources-png-manus/Bible_Source_Texts/" "$homeDir/Documents/Bible_Source_Texts"
rsync -vr --update "/usr/share/wasta-resources-png-manus/StdTexts/" "$homeDir/StdTexts"

#echo
#echo "*** Adjusting ownership and permissions of copied files in user's Home directory"
#echo "Home Directory of user: $USER is $USER"
#echo

#chown -vR $USER:$USER "$USER/Documents/"
#chown -vR $USER:$USER "$USER/StdTexts/"
#chmod -vR ugo+rw "$USER/Documents/"
#chmod -vR ugo+rw "$USER/StdTexts/"

# ------------------------------------------------------------------------------
# Finished
# ------------------------------------------------------------------------------

echo
echo "*** Finished with wasta-resources-png-manus-login-sync-files.sh"
echo

exit 0
