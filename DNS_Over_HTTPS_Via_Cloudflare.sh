#!/bin/bash

#Abort installation if any of the commands fail
set -e

executed_flag="false"
install_aborted="false"

#Confirm internet connectivity
internet_access=$(ping -q -c 1 -W 1 1.1.1.1 > /dev/null 2>&1; echo $?)

#Check if PiHole is already installed, if yes, skip PiHole installation
pihole_working=$(pihole status > /dev/null 2>&1; echo $?)
if [[ ($pihole_working -gt 0)  && ($internet_access == 0) ]]
then
	echo "Proceeding with PiHole installation"
	DIRECTORY="/etc/pihole/"
	if [[ -d "$DIRECTORY" ]]
	then
		echo "PiHole Directory exists." 
	else
		echo "PiHole directory does not exists. Creating directory"
		sudo mkdir /etc/pihole
	fi

	#sudo chown /etc/pihole

	#Find the interface being used
	usedInterface=$(ip addr | awk '/state UP/ {print $2}' | sed 's/.$//')

	#Find the IP Address
	usedIP=$(hostname -I)

	#Find Default Gateway
	RouterIP=$(ip r | awk '/default via/ {print $3}')
	
	#Check if setupVars.conf is present in directory (user rerun of script for custom install)
	if [[ -f setupVars.conf ]]
	then
		echo "setupVars.conf present in directory. Skipping download."
	else
	#Get setupVars.conf file from github
	wget https://raw.githubusercontent.com/piyushkumarjiit/PiHoleWithDoH/master/setupVars.conf
	fi

	#Update the file to use correct Interface and IP of the Pi
	sed -i "s/usedInterface/${usedInterface}/g" setupVars.conf
	sed -i "s/usedIP/${usedIP}/g" setupVars.conf
	sed -i "s/RouterIP/${RouterIP}/g" setupVars.conf
	echo "Updated setupVars.conf"
	sleep 1
	
	#Give user opportunity to update SetupVars.conf for specific usecases
	while true; do
    read -p "Do you need to update SetupVars.conf for custom install? (Yes/No): " user_reply
    case $user_reply in
		#User is ready to proceed with PiHole installation
        [Nn]*) echo "User following Simple install path. Proceeding with PiHole installation.";
		
		#Copy over the setupVars.conf file to /etc/pihole/. This file is used in unattended mode by the installer.
		sudo mv setupVars.conf /etc/pihole/
		echo "setupVars.conf copy complete."

		#Making sure everything is updated on Pi
		sudo apt-get update
		sudo apt-get dist-upgrade
		echo "Enviornment update complete."

		#Downloading Pi-Hole in User Home
		wget -O basic-install.sh https://install.pi-hole.net
		echo "Downloaded the PiHole installer"

		#Installing Pi-Hole in unattended mode
		sudo bash basic-install.sh --unattended

		echo "$(tput setaf 2)PiHole installation complete.$(tput sgr0)"
		executed_flag="true"
		#Remove the pi hole installer after installation.
		rm basic-install.sh
		break;;
		#If user is not ready to proceed with PiHole installation
		[Yy]* ) echo "Please update setupVars.conf and rerun the script."
		echo "User aborted the PiHole installation."; 
		#Do some clean up so that user can re run the installation
		sudo rm -rf /etc/pihole
		install_aborted="true"
		sleep 2;
		break;;
        * ) echo "Please answer Yes or No.";;
    esac
done

elif [[ $internet_access -gt 0 ]]
then
	echo "$(tput setaf 1)No internet. Existing.$(tput sgr0)"
else
	echo "$(tput setaf 1)Pi Hole seems to be already installed, skipping Pi Hole installation$(tput sgr0)"
fi

#Confirm internet connectivity after PiHole installation
internet_access=$(ping -q -c 1 -W 1 1.1.1.1 > /dev/null 2>&1; echo $?)

#Check if Cloudflared proxy is already installed and running
cloudflared_working=$(cloudflared -v > /dev/null 2>&1; echo $?)
if [[ ($cloudflared_working -gt 0) && ($internet_access == 0) && ($install_aborted == "false") ]]
then
	echo "Proceeding with Clouflared Proxy installation"
	
	#Downloading the Cloudflare proxy (Check this page for more details: https://developers.cloudflare.com/argo-tunnel/downloads/)
	cd $Home
	#Check the Model of Pi. There needs to be a separate binary for Zero
	model= $(echo $(cat /proc/cpuinfo | grep Model | grep -e "Zero" -e "Model A"))
	if [[ -n $model ]]
	then
		echo "Pi Zero detected. Downloading binary."
		wget https://hobin.ca/cloudflared/releases/2019.12.0/cloudflared_2019.12.0_arm.tar.gz
		mv cloudflared_2019.12.0_arm.tar.gz cloudflared-stable-linux-arm.tgz
	else
		echo "Pi 3 detected. Downloading binary."
		wget https://bin.equinox.io/c/VdrWdbjqyF/cloudflared-stable-linux-arm.tgz
	fi
	tar -xvzf cloudflared-stable-linux-arm.tgz
	echo "Download and untar complete."

	#Copy the cloudflared binary to local bin and update permissions
	sudo cp cloudflared /usr/local/bin/
	sudo chmod +x /usr/local/bin/cloudflared
	echo "cloudflared copy complete."
	cloudflared -v

	#Add cloudflared User
	user_exists=$(id -u cloudflared > /dev/null 2>&1; echo $?)
	if [[ $user_exists == "1" ]]
	then
		echo "Adding user"
		sudo useradd -s /usr/sbin/nologin -r -M cloudflared
	else
		echo "User exists. Continuing without adding."
	fi

	###Download and save the cloudflared file from github
	cd /etc/default
	sudo wget https://raw.githubusercontent.com/piyushkumarjiit/PiHoleWithDoH/master/cloudflared
	echo "cloudflared download complete."

	#Set correct permissions on cloudflared
	sudo chown cloudflared:cloudflared /etc/default/cloudflared
	sudo chown cloudflared:cloudflared /usr/local/bin/cloudflared
	echo "cloudflared permissions updated."

	#Get the cloudflared service file from github
	cd /lib/systemd/system
	sudo wget https://raw.githubusercontent.com/piyushkumarjiit/PiHoleWithDoH/master/cloudflared.service
	echo "cloudflared service file download complete."

	sudo systemctl enable cloudflared
	sudo systemctl start cloudflared
	echo "cloudflared service enabled and started."
	###probably dont need the next command so commenting it out
	#sudo systemctl status cloudflared

	cd /etc/dnsmasq.d/
	sudo sed -i 's/server=/#server=/g' *
	echo "Updated dnsmasq"

	cd /etc/pihole/
	sudo sed -i 's/PIHOLE_DNS/#PIHOLE_DNS/g' setupVars.conf
	echo "updated setupVars.conf"

	###Get can get the file from github
	cd /etc/dnsmasq.d/ 
	sudo wget https://raw.githubusercontent.com/piyushkumarjiit/PiHoleWithDoH/master/50-cloudflared.conf
	echo "cloudflared.conf download complete."
	executed_flag="true"
	echo "$(tput setaf 2)Cloudflared setup complete.$(tput sgr0)"
elif [[ $internet_access -gt 0 ]]
then
	echo "$(tput setaf 1)No internet. Exiting.$(tput sgr0)"
elif [[ $install_aborted == "true" ]]
then
	echo "$(tput setaf 1)PiHole Install Aborted. Skipping Cloudflared installation.$(tput sgr0)"
else
	echo "Cloudflared already installed. Skipping installation."
fi

### Install Log2ram to reduce the logging impact on the SD Card
### Refer to https://github.com/azlux/log2ram for more details
cd $Home
#Confirm internet connectivity
internet_access=$(ping -q -c 1 -W 1 1.1.1.1 > /dev/null 2>&1; echo $?)
log2ram_present=$(log2ram status > /dev/null 2>&1; echo $?)
if [[ ($log2ram_present != 1) && ($internet_access == 0) && ($install_aborted == "false") ]]
then
	#Fetch the Log2RAM from githib
	curl -Lo log2ram.tar.gz https://github.com/azlux/log2ram/archive/master.tar.gz
	tar xf log2ram.tar.gz
	cd log2ram-master
	chmod +x install.sh && sudo ./install.sh
	cd ..
	#Remove files that are no longer required
	rm -r log2ram-master
	rm log2ram.tar.gz
	executed_flag="true"	
	echo "$(tput setaf 2)Log2ram install complete.$(tput sgr0)"
elif [[ $internet_access -gt 0 ]]
then
	echo "$(tput setaf 1)No internet. Exiting.$(tput sgr0)"
elif [[ $install_aborted == "true" ]]
then
	echo "$(tput setaf 1)PiHole Install Aborted. Skipping Log2RAM installation.$(tput sgr0)"
else
	echo "Log2RAM already installed. Skipping installation."
fi


#####Uninstalling log2ram (if needed in future)
##chmod +x /usr/local/bin/uninstall-log2ram.sh && sudo /usr/local/bin/uninstall-log2ram.sh

###Reboot your Pi-Hole
if [[ $executed_flag == "true" ]]
then
	echo "$(tput setaf 2)Script complete, rebooting.$(tput sgr0)"
	sudo reboot
else
	echo "No changes done. Exiting."
fi
