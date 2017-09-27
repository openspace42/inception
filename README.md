# Debian First Boot Setup

## New: for automated script check out [script.sh](https://github.com/nikksno/ubuntu_first-run-setup/blob/master/script.sh)

00. log in to your newly creater server via ssh as the root user

01. nano /etc/hostname # once inside nano write:
```
	xx01.hello.world
```
02. nano /etc/default/locale # once inside nano delete everything and add this:
```
	LC_ALL=en_US.UTF-8
```
03.01. cd && mkdir -p .ssh

03.02. nano .ssh/authorized_keys # once inside nano paste the ssh public key you copied from your local workstation

03.03. nano /etc/ssh/sshd_config
```
	Port 42022
	PermitRootLogin without-password
	PasswordAuthentication no
```
04. service ssh restart

05. [open new shell and] ssh -p 42022 -i .ssh/privkey-name-here root@xx01.hello.world [and if it works exit the old shell. Proceed on the new shell]

06. reboot

07. dpkg-reconfigure tzdata

08. apt update && apt install screen

09. screen # all commands from now are run from inside screen

10. apt -y upgrade && apt -y dist-upgrade && apt-get -y autoremove && reboot

11.01.  adduser <username> # insert strong password twice at prompt and return all empty values

11.02.  usermod -aG sudo username

11.03.  sudo passwd -dl root

12. reboot

13. apt -y install sudo fail2ban ufw ntp git haveged glances

14. ufw limit 42022 && ufw enable

15. Done!
