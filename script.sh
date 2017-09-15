#!/bin/bash

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

echo At next command, once inside nano make the following changes: (no quotes)
echo "Port 42022"
echo "PermitRootLogin without-password"
echo "PasswordAuthentication no"
echo

sleep 4
nano /etc/ssh/sshd_config
service ssh restart

echo "Now open a new shell and ssh -p 42022 -i .ssh/privkey-name-here root@xx01.hello.world [and check it works]"
echo

echo "The rest of the installation will continue after reboot"
echo

echo "I will reboot in 108 seconds. You can also reboot manually now by issuing the "reboot" command"
echo

sleep 108 && reboot
