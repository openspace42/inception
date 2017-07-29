# ubuntu_first-run-setup

01. nano /etc/default/locale

	LC_ALL=en_US.UTF-8

02. nano /etc/ssh/sshd_config

	Port 42022
	PermitRootLogin without-password
	PasswordAuthentication no
    
03. service ssh restart

04. [open new shell and] ssh servername [and if it works exit the old shell. Proceed on the new shell]

05. reboot

06. dpkg-reconfigure tzdata

07. apt update && apt install screen

08. screen # all commands from now are run from inside screen

09. apt -y upgrade && apt -y dist-upgrade && apt-get -y autoremove && reboot

10.01.  adduser <username> # insert strong password twice at prompt and return all empty values
10.02.  usermod -aG sudo username
10.03.  sudo passwd -dl root

11. reboot

12. apt -y install fail2ban ufw ntp git haveged glances software-properties-common

13. ufw limit 42022 && ufw enable

14. Done!
