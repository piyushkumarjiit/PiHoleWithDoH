#!/bin/bash
#Author: Piyush Kumar (piyushkumar.jiit@.com)

# Script to set local DNS entries on your pi hole.

#Username that we use to connect to remote machine via SSH. sudo or root
USERNAME="piuser"

ALL_DNS_RECORDS_TO_ADD=("grafana.example.com" "dashboard.example.com" "rook.example.com")
ALL_IP_OF_DNS=("192.168.2.191" "192.168.2.190" "192.168.2.190")
node=piholeip

echo "SSH to Pi Hole."
ssh "${USERNAME}"@$node <<- EOF
echo "Connected to $node"
ALL_DNS_RECORDS_TO_ADD=(${ALL_DNS_RECORDS_TO_ADD[*]})
ALL_IP_OF_DNS=(${ALL_IP_OF_DNS[*]})
index=0
for DNS_RECORD_TO_ADD in \${ALL_DNS_RECORDS_TO_ADD[*]}
do
	echo "Processing \$DNS_RECORD_TO_ADD"
	# Add your domain names and IPs in below file on Pi Hole
	DNS_PRESENT=\$(cat /etc/pihole/custom.list | grep \$DNS_RECORD_TO_ADD > /dev/null 2>&1; echo \$?)
	if [[ \$DNS_PRESENT != 0 ]]
	then
		echo "Adding DNS Record to LAN records."
		# Add DNS_RECORD_TO_ADD entry in /etc/pihole/custom.list
		#192.168.2.190 grafana.bifrost.com
		echo "Adding \${ALL_IP_OF_DNS[\$index]} \$DNS_RECORD_TO_ADD"
		sudo bash -c "echo \${ALL_IP_OF_DNS[\$index]} \$DNS_RECORD_TO_ADD >>  /etc/pihole/custom.list"
		echo "Done."
	else
		echo "DNS Record for \$DNS_RECORD_TO_ADD already present in LAN records. No change needed. "	
	fi
	((index++))
done
echo "All DNS records processed. Exiting."
sleep 2
exit
EOF
