# ubuntu_first-run-setup

01. nano /etc/hostname
```
	xx01.hello.world
```
02. nano /etc/default/locale
```
	LC_ALL=en_US.UTF-8
```
03. nano /etc/ssh/sshd_config
```
	Port 42022
	PermitRootLogin without-password
	PasswordAuthentication no
```
04. service ssh restart

05. [open new shell and] ssh servername [and if it works exit the old shell. Proceed on the new shell]

06. reboot

07. dpkg-reconfigure tzdata

08. apt update && apt install screen

09. screen # all commands from now are run from inside screen

10. apt -y upgrade && apt -y dist-upgrade && apt-get -y autoremove && reboot

11.01.  adduser <username> # insert strong password twice at prompt and return all empty values

11.02.  usermod -aG sudo username

11.03.  sudo passwd -dl root

12. reboot

13. apt -y install fail2ban ufw ntp git haveged glances software-properties-common

14. ufw limit 42022 && ufw enable

15. Done!
