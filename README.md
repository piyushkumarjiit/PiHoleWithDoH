# PiHoleWithDoH

Automated Installation of PiHole and DNS Over HTTPS using Cloudflared proxy. It also installs Log2ram to prevent constant writes to SD card.
Aim of this project is to provide user with 1-click (or minimal) set up capability for PiHole along with DNS Over HTTPS.

## Getting Started

Connect to your Raspberry Pi via SSH (or directly using Terminal) and follow installation instructions.
These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See deployment for notes on how to deploy the project on a live system.

### Prerequisites
Basic computer/Raspberry Pi know how
Working Raspberry Pi
SSH access to Raspberry Pi
Access to Internet

The script is mostly self contained or fetches necessary files from github repo.
What things you need to install the software and how to install them

### Installing
#### Simple Installation
In order to execute the script file, run below commands from your Pi terminal (SSH) :

<i>wget https://raw.githubusercontent.com/piyushkumarjiit/PiHoleWithDoH/master/DNS_Over_HTTPS_Via_Cloudflare.sh</i>

Update the permissions on the downloaded file using:

<i>chmod 755 DNS_Over_HTTPS_Via_Cloudflare.sh</i>

Now run the script:

<i>./DNS_Over_HTTPS_Via_Cloudflare.sh  | tee DNS_Over_HTTPS_Via_Cloudflare.log</i>

<b>For advacned installation options, refer to Custom Installation section. </b>

Your Pi would reboot upon completion of script. 

Once it is back up, connect to your Pi (via SSH or terminal) and change the password for PiHole Admin using the command given below:
<i>pihole -a -p <YourNewPassword> </i>

Check the logs to confirm these 2 lines:
<li>PiHole installation complete.</li>
<li>Cloudflared setup complete.</li>
<li>Log2ram install complete.</li>

#### Custom Installation:
These steps are for advacned users who need to customize the installation as per their need.
setupVArs.conf: During the course of execution, this script downloads setupVars.conf file which is used to install PiHole in unattended mode. In case you want to adjust the installation as per your need (Ex: using your existing web server), you can update the file and PiHole installation would proceed accordingly. The script stops in the middle for user to modify the file (in another terminal) and continues upon user confirmation.
Possible configurations:
To prevent installation of web server, set <i>INSTALL_WEB_SERVER=true</i> in the setupVars.conf
To change the interface on which PiHole should run <TBD> in the setupVars.conf

#### Forcing Client with Hardcoded DNS to use PiHole:
HardCodedDNSFilter.sh: This script assumes you have set up key based authentication between your Pi and DD-WRT router. If not, please follow another script/tutorial to set that up before proceeding.
The script dynamically fetches the PiHole IP and SSHs into the Router (using IP fetched by script) to execute another script.
As the router flushes any changes to pre routing on each restart I have kept the router script on my Pi and execute it from here over SSH.
TBD: A way to indetify that PiHole pre routing rule has been removed or check if router has been restarted.

PreRoutingForPi.sh: This script contains commands executed on DD-WRT router (with SSH enabled and configured to use key) to add PiHole IP in the pre routing rules. The script checks if the rule is already present and only updates if it is missing. Please update the port at which your router is listening for SSH.

## Post Installation Steps
If everything went well so far you have a working Pi Hole with Cloudflared proxy setup but now you still need to update your router confing to utilize PiHole as DNS.
Please note you need to update your DNS setting on the LAN tab as well as WAN tab on your router admin page.

## Testing
Once you have updated router config and restarted (or flushed DNS cache on client), run extended tests on dnsleaktest.com and you should see only 1 Cloudflare server in results. 

## Authors
**Piyush Kumar** - (https://github.com/piyushkumarjiit)

## License
This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments
Thanks to below URLs for providing me the necessary understanding and code to come up with this script.
https://docs.pi-hole.net/guides/dns-over-https/
https://bendews.com/posts/implement-dns-over-https/
