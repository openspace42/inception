#!/bin/bash

echo

echo ubuntu_first-run-setup by Nk [https://github.com/nikksno/ubuntu_first-run-setup]
echo

echo "Run this once logged into your newly creater server via ssh as the root user"
echo

echo At next command, once inside nano write: [xx01.hello.world] (change with hostname of machine)
echo

sleep 4
nano /etc/hostname

echo At next command, once inside nano delete everything and add this: "LC_ALL=en_US.UTF-8" (no quotes)
echo

sleep 4
nano /etc/default/locale

echo At next command, once inside nano paste the ssh public key you copied from your local workstation
echo

sleep 4
cd && mkdir -p .ssh
nano .ssh/authorized_keys

echo At next command, once inside nano make the following changes: (no quotes)
echo "Port 42022"
echo "PermitRootLogin without-password"
echo "PasswordAuthentication no"
echo

sleep 4
nano /etc/ssh/sshd_config
service ssh restart

echo "Now open a new shell and ssh -p 42022 -i .ssh/privkey-name-here root@xx01.hello.world [and if it works exit the old shell. Proceed on the new shell]"
echo "I will reboot in 108 seconds. You can also reboot manually now by issuing the "reboot" command"
echo

sleep 108 && reboot
