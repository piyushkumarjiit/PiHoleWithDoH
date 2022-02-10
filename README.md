
# PiHoleWithDoH

Automated Installation of PiHole and DNS Over HTTPS using Cloudflared proxy. It also installs Log2ram to prevent constant writes to SD card.
Aim of this project is to provide user with 1-click (or minimal) set up capability for PiHole along with DNS Over HTTPS.

## Getting Started

Connect to your Raspberry Pi via SSH (or directly using Terminal) and follow installation instructions.
It would be quicker if you have updated your Pi before proceeding with installation. You can use below commands to update your Pi:
<li> <code>sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get dist-upgrade -y && sudo apt-get autoclean -y && sudo apt-get autoremove -y</code> </li>

### Prerequisites
<li>Basic computer/Raspberry Pi know how</li>
<li>Working Raspberry Pi</li>
<li>SSH access to Raspberry Pi</li>
<li>Access to Internet</li>

The script is self contained and fetches necessary files from github repo.

### Installing
#### Simple Installation
For installation, run below commands from your Pi terminal (or SSH session) :

<code>wget https://raw.githubusercontent.com/piyushkumarjiit/PiHoleWithDoH/master/DNS_Over_HTTPS_Via_Cloudflare.sh</code>

Update the permissions on the downloaded file using:

<code>chmod 755 DNS_Over_HTTPS_Via_Cloudflare.sh</code>

Now run below script and follow prompts:

<code>./DNS_Over_HTTPS_Via_Cloudflare.sh  |& tee DNS_Over_HTTPS_Via_Cloudflare.log</code>

<b>Note: For advanced installation options, refer to Custom Installation section. </b>

Your Pi would reboot upon completion of script. 

Once it is back up, connect to your Pi (via SSH or terminal) and change the password for PiHole Admin using the command given below:
<code>pihole -a -p YourNewPassword </code>

For confirming successful installation open the log (DNS_Over_HTTPS_Via_Cloudflare.log) and search for below listed lines:
<li>PiHole installation complete.</li>
<li>Cloudflared setup complete.</li>
<li>Log2ram install complete.</li>


Presence of these lines means that everything went as expected.

#### Custom Installation:
These steps are for advanced users who need to customize the installation as per their need.
setupVars.conf: During the course of execution, this script downloads setupVars.conf file which is used to install PiHole in unattended mode. In case you want to adjust the installation as per your need (Ex: using your existing web server), you can update the file and PiHole installation would proceed accordingly. The script stops in the middle for user to modify the file (in another terminal) and continues upon user confirmation.
Possible configurations:
<li>To prevent installation of web server, set <code>INSTALL_WEB_SERVER=true</code> in the setupVars.conf </li>
<li>To change the interface on which PiHole should run update the setupVars.conf </li>

#### Forcing Client with Hardcoded DNS to use PiHole:
A lot of devices like Chromecast, Fire TV, Roku etc have hardcoded DNS and escape PiHole filters. This raises a need to force these devices to use PiHole by adding a Pre Routing rule on the router.
I did this on my Asus router but it should be similar for other DD WRT based routers.

##### HardCodedDNSFilter.sh:
This script assumes you have set up key based authentication between your Pi and DD-WRT router. If not, please follow relevant script/tutorial to set that up before proceeding. The script dynamically fetches the PiHole IP and SSHs into the Router (using IP fetched by script) to execute another script.
As the router flushes any changes to pre routing on each restart, the router script on Pi should be added to cron and executed via SSH.

##### PreRoutingForPi.sh: 
This script contains commands executed on DD-WRT router (with SSH enabled and configured to use key) to add PiHole IP in the pre routing rules. The script checks if the rule is already present and only updates if it is missing. Please update the port at which your router is listening for SSH.

## Post Installation Steps
If everything went well, you have a working Pi Hole with Cloudflared proxy setup but now you still need to update your router configuration to utilize PiHole as DNS.
Please note you need to update your DNS setting on the LAN tab as well as WAN tab on your router admin page.

## Testing
Once you have updated router config and restarted (or flushed DNS cache on client), run extended tests on https://www.dnsleaktest.com (or http://en.conn.internet.nl/connection/ ) and you should see only 1 Cloudflare server in results. 

For checking PiHole status, run <code> pihole status</code>.

For testing Log2Ram, run <code>df -h | grep log2ram</code> and non empty result would confirm the new mount folder created by Log2Ram.

## Authors
**Piyush Kumar** - (https://github.com/piyushkumarjiit)

## License
This project is licensed under the Apache License - see the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments
Thanks to below URLs for providing me the necessary understanding and material to come up with this script.
<li>https://docs.pi-hole.net/guides/dns-over-https/ </li>
<li>https://github.com/azlux/log2ram</li>
<li>https://bendews.com/posts/implement-dns-over-https/ </li>
<li>https://www.Stackoverflow.com</li>
<li>https://www.DuckDuckGo.com</li>
<li>https://hobin.ca/cloudflared/releases</li>
