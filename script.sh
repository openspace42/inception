#!/bin/bash

sshconfigfile=sshd_config

echo

echo "ubuntu_first-run-setup by nikksno [https://github.com/nikksno/ubuntu_first-run-setup]"
echo

echo "Run this once logged into your newly creater server via ssh as the root user"
echo
read -p "Are you currently root in your target machine (y/N): " confirm && [[ $confirm == [yY] ]] || exit 1
echo

echo "Confirmed. Now continuing..."
echo

read -p "1] Set machine hostname in the format: xm01.hello.world: " hostname
echo
read -p "Is | $hostname | correct? (y/N): " confirm && [[ $confirm == [yY] ]] || exit 1
echo
echo $hostname > /etc/hostname
echo "Hostname set."
echo

echo "2] Now setting correct locale..."
echo
echo "LC_ALL=en_US.UTF-8" > /etc/default/locale
echo "Locale set."
echo

read -p "3] Now paste the ssh public key you copied from your local workstation here: " sshpubkey
echo
read -p "Is it correct? (y/N): " confirm && [[ $confirm == [yY] ]] || exit 1
echo
mkdir -p /root/.ssh/
touch /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys
echo $sshpubkey > /root/.ssh/authorized_keys
echo "SSH Public key set."
echo

echo "4] Now setting SSH hardened values"
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
		echo "Executing APT update..."
		echo
		apt-get update
		echo
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
		echo "Executing APT update"
		echo
		apt-get update
		echo
		echo "Done with APT"
		echo
	fi

else

	echo "Not changing SSHD Port"
	echo
	echo "Executing APT update"
        echo
        apt-get update
        echo
        echo "Done with APT"
        echo

fi

echo "Restarting SSHD"
echo

service ssh restart

echo "Now open a new shell and ssh -p 42022 -i .ssh/privkey-name-here root@xx01.hello.world [and check it works]"
echo

echo "The rest of the installation will continue after reboot"
echo

echo "I will reboot in 108 seconds. You can also reboot manually now by issuing the "reboot" command"
echo

sleep 108 && reboot
