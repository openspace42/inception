#!/bin/bash

currhostname="$(cat /etc/hostname)"
sshauthkeyfile=/root/.ssh/authorized_keys
sshconfigfile=/etc/ssh/sshd_config

echo

echo "ubuntu_first-run-setup by nikksno [https://github.com/nikksno/ubuntu_first-run-setup]"
echo

echo "Run this once logged into your newly creater server via ssh as the root user"
echo
read -p "Are you currently root in your target machine (y/N): " confirm && [[ $confirm == [yY] ]] || exit 1
echo
echo "Confirmed. Now continuing..."
echo

read -p "1] Set machine hostname. It's currently | $currhostname |. Change it? (Y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]
then
	read -p "Ok, changing hostname. Set it in the format: xm01.hello.world: " hostname
	echo
	read -p "Is | $hostname | correct? (y/N): " confirm && [[ $confirm == [yY] ]] || exit 1
	echo
	echo $hostname > /etc/hostname
	echo "Hostname set."
	echo
else
	echo "Skipping hostname change"
	echo
fi

echo "2] Now setting correct locale..."
echo
echo "LC_ALL=en_US.UTF-8" > /etc/default/locale
echo "Locale set."
echo

echo "3] Set SSH public key."
echo
if [ -f /root/.ssh/authorized_keys ]; then
        echo "SSH Authorized Keys file found"
        echo
        currsshauthkeys="$(cat /root/.ssh/authorized_keys)"
        echo "Its content is currently:"
        echo
        echo $currsshauthkeys
        echo
else
	echo "SSH Authorized Keys file NOT found. Creating it now..."
	echo
	mkdir -p /root/.ssh/
        touch /root/.ssh/authorized_keys
fi
chown root /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys
read -p "Set public key now? (Y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]
then
	read -p "Ok, now paste the ssh public key you copied from your local workstation here: " sshpubkey
	echo
	read -p "Is it correct? (y/N): " confirm && [[ $confirm == [yY] ]] || exit 1
	echo
	chmod 600 /root/.ssh/authorized_keys
	echo $sshpubkey > /root/.ssh/authorized_keys
	echo "SSH Public key set."
	echo
else
	echo "Skipping SSH key setting"
	echo
fi

echo "4] Execute APT update"
echo
lastaptupdate="$(date +'%s' -d "$(ls -l /var/cache/apt/pkgcache.bin | cut -d' ' -f6,7,8)")"
lastaptupdatehr="$(date -d "$(ls -l /var/cache/apt/pkgcache.bin | cut -d' ' -f6,7,8)")"
echo "Last update executed on $lastaptupdatehr"
echo
currdate="$(date +'%s')"
difference=$(($currdate-$lastaptupdate))
if (( $difference > 86400 ));
then
        echo "Data is older than 24H. Updating again..."
	echo
	apt-get update
	echo
	echo "APT update complete"
	echo
else
        echo "Data is current enough. Skipping update."
	echo
fi

echo "5] Now setting SSH hardened values"
echo
sed -i "/PermitRootLogin/c\PermitRootLogin prohibit-password" /etc/ssh/sshd_config
echo "Changed 'PermitRootLogin' to 'prohibit-password'."
echo
sed -i "/PasswordAuthentication/c\PasswordAuthentication no" sshd_config
echo "Changed 'PasswordAuthentication' to 'no'."
echo
read -p "Also change SSH port to 42022? (Y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]
then
	if grep -Fq "Port " $sshconfigfile
	then
	        echo "'Port' line found, checking syntax"
	        echo
	        if grep -Eq '^ *Port ' $sshconfigfile; then
	                echo "'Port' syntax correct, changing Port to 42022"
	                echo
	                sed -i "/Port /c\Port 42022" $sshconfigfile
			echo "Port changed to 42022"
			echo
	        else
	                echo "'Port' syntax abnormal [commented, or other]. Re-inserting line with Port set to 42022..."
	                echo
	                sed -i "/Port /c\Port 42022" $sshconfigfile
			echo "Line re-inserted with Port set to 42022"
			echo
	        fi
	else
	        echo "'Port' line not found, adding line with Port set to 42022..."
	        echo
	        sed -i '1iPort 42022' $sshconfigfile
		echo "Line added with Port set to 42022"
		echo
	fi

	read -p "Also install UFW, set 'limit 42022', and enable UFW? (Y/n): " -n 1 -r
	echo
	if [[ ! $REPLY =~ ^[Nn]$ ]]
	then
		echo "Installing UFW"
		echo
		apt-get install ufw
		echo
		echo "Allowing Ports 42022 and 22 [for current session] in 'limit' mode and enabling UFW"
		echo
		ufw limit 42022
		echo
		ufw limit 22
		echo
		ufw enable
		echo
		echo "All done with UFW"
		echo
	else
		echo "Not changing firewall settings. Remember to do so manually right away!"
		echo
	fi

else

	echo "Not changing SSHD Port"
	echo

fi

echo "Restarting SSHD"
echo

service ssh restart
echo

echo "Now, on your workstation, open a new terminal and open a new SSH session to this server with the specified SSH key and on the correct port."
echo
echo "If that works, close that session, come back to this one, and continue running this script, otherwise start over."
echo

read -p "Has the new SSH session worked? (y/N): " confirm && [[ $confirm == [yY] ]] || exit 1
echo

echo "Ok, continuing..."
echo

read -p "6] Now setting timezone. Do so at the next screen. Press enter to continue"
echo

dpkg-reconfigure tzdata
echo

echo "7] Now we're going to create the non-root user."
echo
read -p "1] Set the new user's username: " username
echo
read -p "Is | $username | correct? (y/N): " confirm && [[ $confirm == [yY] ]] || exit 1
echo
echo "Now follow the requestes steps..."
echo
adduser --gecos "" $username
echo
echo "Now allowing newly created user to 'sudo'"
echo
usermod -aG sudo $username
echo "Sudo set"
echo

echo "8] Now unsetting root password"
echo
sudo passwd -dl root
echo "Root password unset"
echo

echo "9] Install recommended packages: sudo fail2ban ufw ntp git haveged glances"
echo
read -p "Should we proceed? (Y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]
then
	apt-get -y install sudo fail2ban ufw ntp git haveged glances
	echo
	echo "Done with APT install"
	echo
else
	echo "Skipping packages install"
	echo
fi

echo "10] It is highly recommended to upgrade all system packages now."
echo
read -p "Should we proceed? (Y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]
then
	apt-get -y upgrade && apt-get -y dist-upgrade && apt-get -y autoremove
        echo
        echo "Done with APT upgrades"
        echo
else
	echo "Skipping APT upgrades"
	echo
fi

echo "11] It is highly recommended to reboot the system now."
echo
read -p "Should we proceed? (Y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]
then
	echo "REBOOTING SYSTEM NOW"
        echo
	echo "Thank you for using this script! Bye!"
	echo
	sleep 4 && reboot
else
	echo "Skipping system reboot. Remember to do so manually as soon as possible!"
	echo
	echo "Thank you for using this script! Bye!"
	echo
fi

exit
