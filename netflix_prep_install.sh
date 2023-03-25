#!/bin/bash
#Set UTF-8; e.g. "en_US.UTF-8" or "de_DE.UTF-8":
export LANGUAGE="en_US.UTF-8"
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
sudo locale-gen en_US.UTF-8

#Tell ncurses to use line characters that work with UTF-8.
export NCURSES_NO_UTF8_ACS=1

cd /home/osmc || exit
# Map parameters to coder-friendly names.
Program="kodi"
version="19"
# thanks DavorPerkovac for TypeO in above varible namne

# Program name must be a valid command.
command -v $Program >/dev/null 2>&1 || { echo "Command: $Program not found."; exit 99; }
InstalledVersion=$( "$Program" --version | perl -pe '($_)=/([0-9]+([.][0-9]+)+)/' )
NonDecIV=${InstalledVersion%.*}
sudo apt-get update 2>&1 | dialog --title "Updating package database and installing needed .deb packages..." --infobox "\nPlease wait...\n" 11 70 
if [[ $NonDecIV -lt $version ]]; then
   if [ ! -d /usr/share/doc/python-crypto ]; then
	sudo apt-get install -q -y python-crypto
   fi
   sudo apt-get install -q -y build-essential python-pip libnss3 libnspr4

   dialog --title "Installing python dependencies..." --infobox "\nPlease wait...\n" 11 70
   sudo pip install -q -U setuptools
   sudo pip install -q wheel
   sudo pip install -q pycryptodomex
else
   dialog --title "Installing python3 dependencies..." --infobox "\nPlease wait...\n" 11 70

   sudo apt-get install python3-crypto python3-pycryptodome python3-pip
fi

if [ ! -d "/home/osmc/addons" ]; then
	mkdir addons
fi
cd addons || exit

dialog --title "Downloading Netflix repository" --infobox "\nPlease wait...\n" 11 70

## Just keeping the last two downloads of the repository
if [ -f "./netflix-repo.zip" ]; then
	if [ -f "./netflix-repo.zip.old" ]; then
		rm netflix-repo.zip.old
	fi
	mv netflix-repo.zip netflix-repo.zip.old
fi

if [[ $NonDecIV -lt $version ]]; then
   wget -q -O netflix-repo.zip https://github.com/CastagnaIT/repository.castagnait/blob/kodi/repository.castagnait-2.0.0.zip
else
   wget -q -O netflix-repo.zip https://github.com/castagnait/repository.castagnait/blob/kodi/repository.castagnait-2.0.0.zip
fi

#fix for non automatic dependcies install, had the same issue with nightly leia
# if [[ $NonDecIV -ge $version ]]; then
#    kodi-send --action="InstallAddon(script.module.addon.signals)"
#    kodi-send --action="InstallAddon(script.module.certifi)"
#    kodi-send --action="InstallAddon(script.module.chardet)"
#    kodi-send --action="InstallAddon(script.module.idna)"
#    kodi-send --action="InstallAddon(script.module.urllib3)"
#    kodi-send --action="InstallAddon(script.module.requests)"
#    dialog --title "Kodi interaction!" --msgbox "\nInstalling some addons needed\nThey need user confirmation, so look at your Kodi screen." 11 70
#    kodi-send --action="InstallAddon(script.module.myconnpy)"
#    kodi-send --action="InstallAddon(script.module.inputstreamhelper)"
# fi

sudo systemctl stop mediacenter
sleep 5
dialog --title "Installation finished!" --msgbox "\nThank you for using my installer\nNow go to addon-browser and choose install from zip\nNavigate to homefolder/addons and install Netflix repository." 11 70
if [ -f "/home/osmc/netflix_prep_install.sh" ]; then
	rm /home/osmc/netflix_prep_install.sh
fi
sudo systemctl start mediacenter



