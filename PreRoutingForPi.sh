#Execute below command to test if PiHole is added to PreRouting. Add in case it is missing.
#Useful for devices with hardcoded DNS. Ex: Chromecast, Roku etc.
echo "Connected to Router, executing script" 
echo "Passed PiHole IP:$1"

#Check if PiHoleIP is present in PreRouting Table
filter_count=$(iptables -t nat -L PREROUTING --line-numbers| grep -c $1)
echo "Count of PiHoleIP in PreRouting Table: $filter_count"

if [ $filter_count -gt 0 ]
then
    echo "Pre Routing Rule is present. Exiting"
else
    echo "Missing Pre Routing Rule. Adding"
	iptables -t nat -A PREROUTING ! -s $1 -i br0 -p tcp --dport 53 -j DNAT --to $1
	iptables -t nat -A PREROUTING ! -s $1 -i br0 -p udp --dport 53 -j DNAT --to $1
fi
echo "Router processing complete."
exit
