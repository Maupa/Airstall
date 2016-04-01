#!/bin/bash

# Logger
exec 1> >(logger -s -t "Airstall: "$(basename $0)) 2>&1

SETUPL="/Users/Shared/SETUP_FILES" # mount share
TEMP="/Users/Shared/SETUP_TEMP"    # TEMP FOLDER

ADDRESS="example.com/macbook_install"

ADUSER="admin" # Active directory username
ADPASS="1di0t" # ...and his password

echo "Creating temp folders"$'\n'
	mkdir $SETUPL
	mkdir $TEMP
echo "Done."$'\n\n'

echo "Mounting share."$'\n'
	mount_smbfs "//"$ADUSER":"$ADPASS"@"$ADDRESS $SETUPL #Mounts SMB volume
	sleep 3
echo "Done."$'\n\n'


echo "Copying files"$'\n'
	cp -R $SETUPL/* $TEMP/
echo "Done."$'\n\n'


echo "Unmounting Share"$'\n'
	umount $SETUPL
echo "Done."$'\n\n'


echo "Executing install script in the background process"$'\n'
	screen -dmS bash $TEMP"/airstall.sh"
echo "Done."$'\n\n'


echo "Running install script..."