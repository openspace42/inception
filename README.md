# inception

## What it is and what it does

This is our reference first boot script for any Debian / Ubuntu server and will perform the following actions:

01. Prompt you to update the machine hostname
02. Set your default locale to something that actually works
03. Harden your SSH config by:
03.01. Prompting you to add your SSH public key and disable password authentication for secure key-based remote login
03.02. Prompting you to change the SSH listening port to 42022
03.04. Adding whichever port you choose to the UFW allowed ports, install and enable UFW
04. Prompt you to set the correct timezone for the machine
05. Unset the default root password just in case
06. Create a non-root user and allowing it to sudo
07. Install essential system utilities that you'll love
08. Performing a full APT update / upgrade / dist-upgrade / autoremove
