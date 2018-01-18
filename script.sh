#!/bin/bash

set -e
set -u

# Don't change | No trailing slash
projname="Debian-First-Boot-Setup"
sourcedir=/root/$projname
basedir=/root/openspace42
installdir=$basedir/dfbs

mkdir -p $installdir

currhostname="$(cat /etc/hostname)"
sshauthkeyfile=/root/.ssh/authorized_keys
sshconfigfile=/etc/ssh/sshd_config
currusers="$(cat /etc/passwd | cut -d: -f 1,3,6 | grep "[1-9][0-9][0-9][0-9]" | grep "/home" | cut -d: -f1)"

r=`tput setaf 1`
g=`tput setaf 2`
l=`tput setaf 4`
m=`tput setaf 5`
x=`tput sgr0`
b=`tput bold`

echo

echo "${b}Debian First Boot Setup by Nk [openspace].${x}"
echo

if [[ $EUID -ne 0 ]]
then
	echo "This script must be run as root. Run it as:"
	echo
	echo "sudo bash $sourcedir"
	echo
	exit
fi

# Delete old installdir

if [ -d /root/os-dfbs ]
then
	rm -r /root/os-dfbs
fi

################################################################################



read -p "${b}1] Set machine hostname. It's currently | $currhostname |. Change it? (Y/n): ${x}" -n 1 -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]
then
	defined=n
	until [ $defined = "y" ]
	do
		hostname=""
		until [ ! $hostname = "" ]
		do
			read -p "${b}Ok, changing hostname. Set it in the format: xm01.hello.world: ${x}" hostname
			echo
		done
		valid=n
		until [ $valid = "y" ]
		do
			read -n 1 -p "${b}Is | $hostname | correct? (Y/n/e[xit]) ${x}" answer;
			case $answer in
			"")
				echo
				valid=y
				defined=y
				;;
			y)
				echo -e "\n"
				valid=y
				defined=y
				;;
			n)
				echo -e "\n"
				echo "${b}Ok, then please try again...${x}"
				echo
				valid=y
				defined=n
				;;
			e)
				echo -e "\n"
				echo "${b}Exiting...${x}"
				echo
				exit
				;;
			*)
				echo -e "\n"
				echo "${r}${b}Invalid option. Retry...${x}"
				echo
				valid=n
				defined=n
				;;
			esac
		done
	done
	echo $hostname > /etc/hostname
	echo "${b}New hostname set to | $hostname |.${x}"
	echo
else
	echo
	echo "${b}Leaving hostname set to | $currhostname |.${x}"
	echo
fi



echo "${b}2] Now setting correct locale...${x}"
echo
echo "LC_ALL=en_US.UTF-8" > /etc/default/locale
echo "${b}Locale set.${x}"
echo



echo "${b}3] Set your SSH public key...${x}"
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
	defined=n
	until [ $defined = "y" ]
	do
		sshpubkey=""
		until [ ! "$sshpubkey" = "" ]
		do
			read -p "${b}Ok, now paste the ssh public key you copied from your local workstation here: ${x}" sshpubkey
			echo
		done
		valid=n
		until [ $valid = "y" ]
		do
			read -n 1 -p "${b}Is it correct? (Y/n/e[xit]) ${x}" answer;
			case $answer in
			"")
				echo
				valid=y
				defined=y
				;;
			y)
				echo -e "\n"
				valid=y
				defined=y
				;;
			n)
				echo -e "\n"
				echo "${b}Ok, then please try again...${x}"
				echo
				valid=y
				defined=n
				;;
			e)
				echo -e "\n"
				echo "${b}Exiting...${x}"
				echo
				exit
				;;
			*)
				echo -e "\n"
				echo "${r}${b}Invalid option. Retry...${x}"
				echo
				valid=n
				defined=n
				;;
			esac
		done
	done
	chmod 600 /root/.ssh/authorized_keys
	echo "$sshpubkey" > /root/.ssh/authorized_keys
	echo "SSH Public key set."
	echo
else
	echo
	echo "Skipping SSH key setting"
	echo
fi



echo "${b}4] Now executing APT update...${x}"
echo
apt-get update
echo



echo "${b}5] Now setting SSH hardened values...${x}"
echo
sed -i "/PermitRootLogin/c\PermitRootLogin without-password" $sshconfigfile
echo "Changed 'PermitRootLogin' to 'without-password'."
echo
sed -i "/PasswordAuthentication/c\PasswordAuthentication no" $sshconfigfile
echo "Changed 'PasswordAuthentication' to 'no'."
echo
echo "Now checking current SSH port setting..."
echo

if grep -Fq "Port " $sshconfigfile
then
	echo "'Port' line found, checking syntax"
	echo
	if grep -Eq '^ *Port ' $sshconfigfile
	then
		echo "'Port' syntax correct"
		echo
		if grep -Eq '^ *Port 42022' $sshconfigfile
		then
			echo "SSH port already set to 42022."
			echo
			sshport=42022
		else
			currsshport="$(grep '^ *Port *' /etc/ssh/sshd_config | sed 's|Port ||g')"
			echo "SSH port currently set to $currsshport"
			echo
			read -p "Change it to 42022? (Y/n): " -n 1 -r
			echo
			if [[ ! $REPLY =~ ^[Nn]$ ]]
			then
				echo "Ok, changing Port to 42022"
				echo
				sed -i "/Port /c\Port 42022" $sshconfigfile
				echo "Port changed to 42022"
				echo
				sshport=42022
			else
				echo "Leaving SSH port set to $currsshport"
				echo
				sshport=$currsshport
			fi
		fi
	else
		read -p "'Port' syntax abnormal [commented, or other]. Fixing it now. Also set it to 42022? (Y/n): " -n 1 -r
		echo
		if [[ ! $REPLY =~ ^[Nn]$ ]]
                then
                        echo "Ok, fixing syntax and setting 'Port' to 42022"
                        echo
                        sed -i "/Port /c\Port 42022" $sshconfigfile
			echo "Line re-inserted with Port set to 42022"
			echo
			sshport=42022
		else
			echo
			echo "Ok, fixing syntax but leaving 'Port' set to 22 [standard]"
                        echo
                        sed -i "/Port /c\Port 22" $sshconfigfile
			echo "Line re-inserted with Port set to 22"
			echo
			sshport=22
	        fi
	fi
else
	read -p "'Port' line not found. Add it now. Also set it to 42022? (Y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Nn]$ ]]
        then
                echo "Ok, adding 'Port' line and setting it to 42022"
                echo
		sed -i '1iPort 42022' $sshconfigfile
                echo "Line added with 'Port' set to 42022"
                echo
		sshport=42022
        else
		echo
                echo "Ok, adding 'Port' line but leaving it set to 22 [standard]"
                echo
		sed -i '1iPort 22' $sshconfigfile
                echo "Line added with 'Port' set to 22"
                echo
		sshport=22
        fi
fi

touch $installdir/ssh-port
echo $sshport > $installdir/ssh-port



echo "${b}6] Now installing UFW, setting 'limit $sshport', and enabling UFW.${x}"
echo
apt-get -y install ufw
echo "Allowing Port $sshport"
echo
ufw limit $sshport
echo
if [ ! $sshport = 22 ]
then
	echo "Also setting 'limit 22' [for current session]"
	echo
	ufw limit 22
	echo
fi
echo "Enabling UFW"
echo
ufw  --force enable
echo
echo "All done with UFW"
echo

echo "${b}Restarting SSHD...${x}"
echo
service ssh restart



echo "Now, on your workstation, open a new terminal and open a new SSH session to this server with the specified SSH key and on the correct port."
echo
echo "If that works, close that session, come back to this one, and continue running this script, otherwise start over."
echo
read -p "Has the new SSH session worked? (y/N): " confirm && [[ $confirm == [yY] ]] || exit 1
echo
echo "Ok, continuing..."
echo



read -p "7] Now setting timezone. Do so at the next screen. Press enter to continue"
echo
dpkg-reconfigure tzdata
echo



echo "${b}8] Create a user on this machine other than root.${x}"
echo
echo "${b}The current non-root full users with a home directory are:${x}"
echo
echo $currusers
echo
read -p "Add non-root user now? (Y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]
then
	defined=n
	until [ $defined = "y" ]
	do
		newuser=""
		until [ ! $newuser = "" ]
		do
			read -p "${b}Ok, adding user now. Specify the new user's username: ${x}" newuser
			echo
		done
		valid=n
		until [ $valid = "y" ]
		do
			read -n 1 -p "${b}Is | $newuser | correct? (Y/n/e[xit]) ${x}" answer;
			case $answer in
			"")
				echo
				valid=y
				defined=y
				;;
			y)
				echo -e "\n"
				valid=y
				defined=y
				;;
			n)
				echo -e "\n"
				echo "${b}Ok, then please try again...${x}"
				echo
				valid=y
				defined=n
				;;
			e)
				echo -e "\n"
	        		echo "${b}Exiting...${x}"
	        		echo
	        		exit
	        		;;
			*)
				echo -e "\n"
				echo "${r}${b}Invalid option. Retry...${x}"
	        		echo
				valid=n
			defined=n
		        ;;
			esac
		done
	done
	adduser --disabled-password --gecos "" $newuser
	usermod -aG sudo $newuser
else
	echo
	echo "${b}Skipping non-root user creation.${x}"
	echo
fi



echo "${b}9] Now unsetting root password...${x}"
echo
sudo passwd -dl root
echo
echo "${b}Root password unset.${x}"
echo



echo "${b}10] Now installing other packages...${x}"
echo

distro="$(lsb_release --id | cut -f2)"

if [ $distro = "Ubuntu" ]
then

	echo "${g}${b}Detected Ubuntu distro. Proceeding with full install...${x}"
	echo

	hostname="$(cat /etc/hostname)"
	debconf-set-selections <<< "postfix postfix/mailname string $hostname"
	debconf-set-selections <<< "postfix postfix/main_mailer_type string 'Internet Site'"
	apt-get install -y mailutils
	/etc/init.d/postfix reload

else

	echo "${r}${b}Detected NON-Ubuntu distro [mail notifications might not work]. Proceeding...${x}"
	echo

fi

apt-get -y install sudo software-properties-common curl ntp dnsutils haveged cronic fail2ban git glances htop pwgen pv bc
echo
echo "${b}Done with APT install.${x}"
echo



echo "${b}11] Now upgrading all system packages...${x}"
echo
apt-get -y upgrade && apt-get -y dist-upgrade && apt-get -y autoremove
echo
echo "${b}Done with APT upgrades.${x}"
echo



echo "${b}12] Rebooting system now to complete installation...${x}"
echo
echo "${g}${b}All done!${x}"
echo
sleep 4 && touch $installdir/run-ok && rm -r $sourcedir && reboot
