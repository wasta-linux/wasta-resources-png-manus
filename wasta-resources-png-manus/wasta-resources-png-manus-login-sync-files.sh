#!/bin/bash

# ==============================================================================
# wasta-resources-png-manus-postinst.sh
#
#   This script is copied to /etc/profiles.d/ when the wasta-resources-png-manus
#   package is installed. It is installed by the debian/install script as root.
#   This script automatically run at each user login. It can be manually re-run, 
#       but is only intended to be run at package installation.  
#
#   2016-07-25 whm: initial script
#                   Copies resource docs from /usr/share/wasta-resources-png-manus
#                   to user's home dir to make it easier for user to find and/or 
#                   edit selected resource documents/files.
#                   Uses the rsync --update option for copying to skip any files
#                   for which the destination file already exists and has a date 
#                   later than the source file. 
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

#echo
#echo "*** Beginning wasta-resources-png-manus-login-sync-files.sh"
#echo

# ------------------------------------------------------------------------------
# Copy/Sync resources from /usr/share/wasta-resources-png-manus to user's Home dir
# ------------------------------------------------------------------------------
#echo
#echo "*** Copying resources to user's Home directory"
# Note: Calling logname and the environment's $USER return root during installation of packages
# $SUDO_USER, however seems to work for determining the user's home directory name
user=$SUDO_USER
homeDir="/home/$user"
#echo "Home Directory of user: user variable is $homeDir"
#echo "Home Directory of user: USER variable is $USER"

#echo "Dry Run calling (-n option) of rsync..."
rsync -vrn --update "/usr/share/wasta-resources/PNG Manus Resources/" "$USER/Documents"
rsync -vrn --update "/usr/share/wasta-resources-png-manus/Bible_Source_Texts/" "$USER/Documents/Bible_Source_Texts"
rsync -vrn --update "/usr/share/wasta-resources-png-manus/StdTexts/" "$USER/StdTexts"

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

#echo
#echo "*** Finished with wasta-resources-png-manus-login-sync-files.sh"
#echo

exit 0
