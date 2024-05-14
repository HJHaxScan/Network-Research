#!/bin/bash

#! 1. Installations and Anonymity Check

#! 1.2 If the applications are already installed, don’t install them again

app1="geoiplookup"
app2="tor"
app3="sshpass"

if [[ $(which $app1) != "" ]]; 

	then
	echo "$app1 is installed"

	else
	echo "$app1 is not installed"
	echo "Installing $app1..."
	sudo apt-get install geoip-bin
	echo "Installation for $app1 completed"
	
fi


if [[ $(which $app2) != "" ]]; 

	then
	echo "$app2 is installed"

	else
	echo "$app2 is not installed"
	echo "Installing $app2..."
	sudo apt-get install $app2
	echo "Installation for $app2 completed"
	
fi

if [[ $(which $app3) != "" ]]; 

	then
	echo "$app3 is installed"

	else
	echo "$app3 is not installed"
	echo "Installing $app3..."
	sudo apt-get install $app3
	echo "Installation for $app3 completed"
	
fi

if [[ $(sudo find / -type f -name nipe.pl 2>/dev/null) != '' ]];

	then
	echo "Nipe is installed"
	
	else
	echo "Nipe is not installed"
	echo "Installing Nipe..."
	
	git clone https://github.com/htrgouvea/nipe && cd nipe
	sudo apt-get install cpanminus
	sudo cpanm --installdeps .
	sudo perl nipe.pl install
	
	echo "Installation for Nipe completed"
	
fi

#! 1.3 Check if the network connection is anonymous; if not, alert the user and exit

echo -e
if [[ $(sudo netstat -tpan | grep tor) == "" ]]

	then
	echo "Your connection is not anonymous, aborting mission! Please enable your tor service!"
	exit
	
	#! 1.4 If the network connection is anonymous, display the spoofed country name
	
	else
	echo "Your connection is anonymous, establishing connection with remote server..."
	
	spoofedip=$(sudo netstat -tpan | grep -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | awk '{print $(NF-2)}' | grep -E '(9001|9030|9040|9050|9051|9150)' | awk -F: 'NR==1 {print $1}')
	spoofedcountry=$(geoiplookup $spoofedip | awk -F: '{print $2}')
	
	echo "Your Spoofed IP Address is : $spoofedip"
	echo "Your Spoofed Country is : $spoofedcountry"
	
fi

#! 1.5 Allow the user to specify the address to scan via remote server; save into a variable\

echo -e

echo "Please enter the Domain/IP to be scanned :" 
read IP

#! 2. Automatically Connect and Execute Commands on the Remote Server via SSH

#! 2.1 Display the details of the remote server (country, IP, and Uptime)

echo -e

UPT=$(sshpass -p tc ssh tc@$IP uptime)
IPR=$(sshpass -p tc ssh tc@$IP hostname -I)
Country=$(whois $IP | grep -i country | awk '{print $2}' | tr -s " ")
RC=$(sshpass -p tc ssh tc@$IP echo $Country)

echo "Logging in to remote server..."
echo -e
echo "Uptime : $UPT"
echo "This is the remote server IP Address : $IPR"
echo "This is the remote server country : $RC"

#! 2.2 Get the remote server to check the Whois of the given address
#! 3. Results
#! 3.1 Save the Whois and Nmap data into files on the local computer

echo -e

date=$(date "+%c %Y")

echo "Collecting information on victim's server using Whois..."

#! 3.1 Save the Whois and Nmap data into files on the local computer
mkdir -p /home/kali/Desktop/NR/whois
whois $IP > /home/kali/Desktop/NR/whois/whois_$IP

echo "Creating directories..."
echo "Information collected and stored at /home/kali/Desktop/NR/whois as whois_$IP"

#! 3.2 Create a log and audit your data collecting
mkdir -p /home/kali/Desktop/NR/logs
echo "$date whois data collected for : $IP" >> /home/kali/Desktop/NR/logs/nr_nmap_whois.log

#! 2.3 Get the remote server to scan for open ports on the given address

echo -e

echo "Scanning all open ports for victim's server using nmap..."

#! 3.1 Save the Whois and Nmap data into files on the local computer
mkdir -p /home/kali/Desktop/NR/nmap
nmap $IP > /home/kali/Desktop/NR/nmap/nmap_$IP

echo "Creating directories..."
echo "Open ports scanned and saved into /home/kali/Desktop/NR/nmap as nmap_$IP"

#! 3.2 Create a log and audit your data collecting
echo "$date Nmap data collected for : $IP" >> /home/kali/Desktop/NR/logs/nr_nmap_whois.log
