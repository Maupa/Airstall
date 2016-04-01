#!/bin/bash

# Logger
exec 1> >(logger -s -t "Airstall: "$(basename $0)) 2>&1

PROXYPAC="http://proxy.example.com/proxy.pac" # Proxy setting
ODSSERVER="ods-01.example.com" # ODS Server
NTPSERVER="time.example.com" #NTP server

ROOTPASS="id10t" #root password

# Active Directory
ADDOMAIN="example.com" # Active Directory Domain
ADUSER="admin" # Active directory username
ADPASS="1di0t" # ...and his password

TEMP="/Users/Shared/SETUP_TEMP" # Temp data

echo "Setting time server"$'\n'
	systemsetup -settimezone Pacific/Auckland
	systemsetup -setnetworktimeserver $NTPSERVER
echo "Done."$'\n\n'


echo "Adding KAMAR link"$'\n'
	KAMARDIR="/Users/Shared/KAMAR_12"
	mkdir $KAMARDIR
	cd $KAMARDIR
	cp $TEMP/KAMAR/KAMAR.fmp12 .
	chmod 644 KAMAR.fmp12 #fix the permision.
echo "Done."$'\n\n'


echo "Installing packages"$'\n\n'
	cd $TEMP/Packages
	for f in ./*.*pkg
	do
		echo "   Installing $f"$'\n'
		/usr/sbin/installer -pkg "$f" -target / -allowUntrusted
		echo "   Done."$'\n\n'
	done
echo "Done."$'\n\n'


echo "Copying applications over"$'\n'
	chmod -R 755 $TEMP/Applications
	cp -R $TEMP/Applications/* /Applications
echo "Done."$'\n\n'


echo "Setting root password."$'\n'
	dscl . -passwd /Users/admin $ROOTPASS #Change admin password
echo "Done."$'\n\n'


echo "Setting 'Display login window as: Name and password'"$'\n'
	defaults write /Library/Preferences/com.apple.loginwindow.plist SHOWFULLNAME -bool true
echo "Done."$'\n\n'


echo "Setting proxy settings."$'\n'
	networksetup -setautoproxyurl Wi-Fi $PROXYPAC
echo "Done."$'\n\n'

# https://support.symantec.com/en_US/article.TECH103489.html
# Download RemoveSymantecMacFiles.zip from the following address:
# ftp://ftp.symantec.com/misc/tools/mactools/RemoveSymantecMacFiles.zip
echo "Removing Symatec."$'\n' # Cause F*** symatech
	echo 1 | bash $TEMP/RemoveSymantecMacFiles.command
echo "Done."$'\n\n'


echo "Removing temp folders"$'\n'
	rm -rf $TEMP
echo "Done."$'\n\n'


echo "Unbinding ODS"$'\n' # Fix for auto ODS binding.
	/usr/sbin/dsconfigldap -f -v -r $ODSSERVER
echo "Done."$'\n\n'


echo "Remove popup proxy"$'\n'
	launchctl unload -w /System/Library/LaunchDaemons/com.apple.UserNotificationCenter.plist
echo "Done."$'\n\n'


echo "Adding computer to Active Directory"$'\n'
	# Set HostName, LocalHostName, and ComputerName to M$SN
	DIRTY_CNAME=`scutil --get ComputerName`
	CNAME=${DIRTY_CNAME// /-} #Replacing spaces with hyphen

	scutil --set HostName $CNAME
	scutil --set LocalHostName $CNAME
	scutil --set ComputerName $CNAME

	echo "y" | dsconfigad -add $ADDOMAIN -username $ADUSER -password $ADPASS
echo "Done."$'\n\n'


echo "Opening popup to inform about completion of the installation"$'\n'
	osascript -e 'tell app "Finder" to display dialog "Airstall: Installation complete!"'
echo "Done."$'\n\n'


echo "Installation Complete!"
