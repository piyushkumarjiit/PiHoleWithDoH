#!/bin/bash


sudo mkdir /etc/pihole/
#sudo chown /etc/pihole/

#Find the interface being used
usedInterface=$(ip addr | awk '/state UP/ {print $2}' | sed 's/.$//')

#Find the IP Address
usedIP=$(hostname -I)

#Get setupVars.conf file from github
wget https://raw.githubusercontent.com/piyushkumarjiit/PiHoleWithDoH/master/setupVars.conf

#Update the file to use correct Interface and IP of the Pi
sed -i "s/usedInterface/${usedInterface}/g" setupVars.conf
sed -i "s/usedIP/${usedIP}/g" setupVars.conf

#Making sure everything is updated on Pi
sudo apt-get update
sudo apt-get dist-upgrade

#Downloading Pi-Hole
wget -O basic-install.sh https://install.pi-hole.net

#Installing Pi-Hole
sudo bash basic-install.sh --unattended


#Downloading the Cloudflare proxy (Check this page for more details: https://developers.cloudflare.com/argo-tunnel/downloads/)
wget https://bin.equinox.io/c/VdrWdbjqyF/cloudflared-stable-linux-arm.tgz
tar -xvzf cloudflared-stable-linux-arm.tgz
sudo cp ./cloudflared /usr/local/bin
sudo chmod +x /usr/local/bin/cloudflared
cloudflared -v

sudo useradd -s /usr/sbin/nologin -r -M cloudflared

###Get the file from github
wget https://raw.githubusercontent.com/piyushkumarjiit/PiHoleWithDoH/master/cloudflared
#Uncomment below lines if download fails
#cat <<EOF >/etc/default/cloudflared
#CLOUDFLARED_OPTS=--port 5053 --upstream https://1.1.1.1/dns-query
#EOF

#Set correct permissions
sudo chown cloudflared:cloudflared /etc/default/cloudflared
sudo chown cloudflared:cloudflared /usr/local/bin/cloudflared

#Get the service file from github
wget https://raw.githubusercontent.com/piyushkumarjiit/PiHoleWithDoH/master/cloudflared.service


sudo systemctl enable cloudflared
sudo systemctl start cloudflared
###probably dont need the next command so commenting it out
#sudo systemctl status cloudflared

cd /etc/dnsmasq.d/
sed -i 's/server=/#server=/g' *

cd /etc/pihole/
sed -i 's/PIHOLE_DNS/#PIHOLE_DNS/g' setupVars.conf

###Get can get the file from github
sudo cd /etc/dnsmasq.d/ 
wget https://raw.githubusercontent.com/piyushkumarjiit/PiHoleWithDoH/master/50-cloudflared.conf
#If download fails, uncomment below 3 lines
#cat <<EOF >/etc/dnsmasq.d/50-cloudflared.conf
#server=127.0.0.1#5053
#EOF


### Install Log2ram to reduce the logging impact on the SD Card
### Refer to https://github.com/azlux/log2ram for more details
cd ~
curl -Lo log2ram.tar.gz https://github.com/azlux/log2ram/archive/master.tar.gz
tar xf log2ram.tar.gz
cd log2ram-master
chmod +x install.sh && sudo ./install.sh
cd ..
rm -r log2ram-master

#####Uninstalling log2ram (if needed in future)
##chmod +x /usr/local/bin/uninstall-log2ram.sh && sudo /usr/local/bin/uninstall-log2ram.sh

###Reboot your Pi-Hole
sudo reboot





