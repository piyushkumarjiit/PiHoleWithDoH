# PiHoleWithDoH
Automated Installation of PiHole and DNS Over HTTPS using Cloudflared.
Aim of this project is to provide user with 1-click (or minimal) set up capability for PiHole along with DNS Over HTTPS.
There are subscripts that update prerouting rules on DD-WRT router (tested on Asus RT68U) to capture traffic from devices with hardcoded DNS (Ex: Chromecast, Roku etc.).

#Simple Installation:
In order to execute the script file, run below commands from your Pi terminal (SSH) :

wget https://raw.githubusercontent.com/piyushkumarjiit/PiHoleWithDoH/master/DNS_Over_HTTPS_Via_Cloudflare.sh

Update the permissions on the downloaded file using:

chmod 755 DNS_Over_HTTPS_Via_Cloudflare.sh

Now run the script:

./DNS_Over_HTTPS_Via_Cloudflare.sh  | tee DNS_Over_HTTPS_Via_Cloudflare.log

Do not forget to update your PiHole Admin password. Use command given below:
pihole -a -p YourNewPassword

#Custom Installation:

setupVArs.conf: During the course of execution, this script downloads setupVars.conf file which is used to install PiHole in unattended mode. In case you want to adjust the installation as per your need (Ex: using your existing web server), you can update the file and PiHole installation would proceed accordingly. The script stops in the middle for user to modify the file (in another terminal) and continues upon user confirmation.
To prevent installation of web server you set INSTALL_WEB_SERVER=true in the setupVars.conf.

HardCodedDNSFilter.sh: This script assumes you ahve set up key based authentication between your Pi and DD-WRT router. If not, please follow another script/tutorial to set that up before proceeding.
The script dynamically fetches the PiHole IP and SSHs into the Router (using IP fetched by script) to execute another script.
As the router flushes any changes to pre routing on each restart I have kept the router script on my Pi and execute it from here over SSH.
TBD: A way to indetify that PiHole pre routing rule has been removed or check if router has been restarted.

PreRoutingForPi.sh: This script contains commands executed on DD-WRT router (with SSH enabled and configured to use key) to add PiHole IP in the pre routing rules. The script checks if the rule is already present and only updates if it is missing. Please update the port at which your router is listening for SSH.
