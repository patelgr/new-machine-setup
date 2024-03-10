```markdown
# Raspberry Pi Security and Maintenance Guide

This guide provides comprehensive steps for securing and maintaining your Raspberry Pi, including system updates, SSH security, user management, firewall setup, and more. Follow these instructions to enhance the security and efficiency of your system.

## Table of Contents

1. [Changing the Default Password](#1-changing-the-default-password)
2. [Keeping the OS Updated](#2-keeping-the-os-updated)
3. [Securing the SSH Connection](#3-securing-the-ssh-connection)
4. [Setting up a Firewall](#4-setting-up-a-firewall)
5. [Using Fail2Ban to Block Attackers](#5-using-fail2ban-to-block-attackers)
6. [Limiting Access with User Accounts](#6-limiting-access-with-user-accounts)
7. [Disabling Unnecessary Services](#7-disabling-unnecessary-services)
8. [Making Sudo Require a Password](#8-making-sudo-require-a-password)
9. [Monitoring and Logging Network Activity](#9-monitoring-and-logging-network-activity)
10. [Enable Public Key Infrastructure (PKI) for SSH](#10-enable-public-key-infrastructure-pki-for-ssh)
11. [Secure Network Services: Using Non-Standard Ports](#11-secure-network-services-using-non-standard-ports)
12. [Install PortSentry to Detect and Respond to Port Scans](#12-install-portsentry-to-detect-and-respond-to-port-scans)
13. [Implement Rate Limiting on Login Attempts](#13-implement-rate-limiting-on-login-attempts)
14. [Disable Unnecessary Components](#14-disable-unnecessary-components)
15. [Read-Only Filesystem for Critical Components](#15-read-only-filesystem-for-critical-components)
16. [Secure Boot Settings](#16-secure-boot-settings)
17. [Encrypt Sensitive Data](#17-encrypt-sensitive-data)
18. [Disable or Uninstall Unnecessary Packages](#18-disable-or-uninstall-unnecessary-packages)
19. [Additional Recommendations](#19-additional-recommendations)

## 1. Changing the Default Password

### Command:
```bash
passwd
```

### Verification:
Log in with the new password to ensure it has been changed.

## 2. Keeping the OS Updated

### Commands:
```bash
sudo apt update  # Update package list
sudo apt full-upgrade  # Upgrade packages
```

### Verification:
```bash
sudo apt list --upgradable  # Confirm no pending upgrades
```

## 3. Securing the SSH Connection

### SSH key authentication:
```bash
ssh-keygen  # Generate keys
ssh-copy-id user@raspberrypi  # Copy to Raspberry Pi
```

### Disable root login and implement two-factor authentication:
```bash
sudo sed -i '/PermitRootLogin/c\PermitRootLogin no' /etc/ssh/sshd_config
sudo service ssh restart
```

### Verification:
Try to SSH without the key and as root to ensure it's not permitted.

## 4. Setting up a Firewall

### Enable UFW and set default rules:
```bash
sudo ufw enable
sudo ufw default deny incoming
sudo ufw default allow outgoing
```

### Allow necessary services:
```bash
sudo ufw allow ssh
sudo ufw allow http
sudo ufw allow https
```

### Verification:
```bash
sudo ufw status  # Check rules
```

## 5. Using Fail2Ban to Block Attackers

### Install Fail2Ban:
```bash
sudo apt install fail2ban
```

### Verification:
Simulate failed login attempts and check Fail2Ban logs:
```bash
sudo fail2ban-client status sshd  # Check banned IPs
```

## 6. Limiting Access with User Accounts

### Create a new user and grant sudo privileges:
```bash
sudo adduser newuser  # Replace 'newuser' with your desired username
sudo usermod -aG sudo newuser  # Replace 'newuser' with the username you just created
```

### Disable default user 'pi':
```bash
sudo usermod -L pi  # Replace 'pi' with any default user you wish to disable
```

### Verification:
Try to log in as 'pi' to ensure the account is disabled and verify 'newuser' has sudo access.

## 7. Disabling Unnecessary Services

### List running services and disable unnecessary ones:
```bash
service --status-all
sudo systemctl disable servicename  # Replace 'servicename' with the service you wish to disable
```

###

 Verification:
```bash
systemctl status servicename  # Replace 'servicename' with the service you've disabled
```

## 8. Making Sudo Require a Password

### Check and edit /etc/sudoers if NOPASSWD is set:
```bash
grep NOPASSWD /etc/sudoers
sudo sed -i '/NOPASSWD/d' /etc/sudoers
```

### Verification:
Ensure sudo asks for a password:
```bash
sudo -l
```

## 9. Monitoring and Logging Network Activity

### Install monitoring tools:
```bash
sudo apt install wireshark logwatch
```

### Verification:
Use Wireshark to capture packets and check Logwatch for suspicious activity.


## 10. Enable Public Key Infrastructure (PKI) for SSH

### Generate SSH keys on the client machine:
```bash
ssh-keygen -t rsa -b 4096
```

### Copy the public key to the Raspberry Pi:
```bash
ssh-copy-id -i ~/.ssh/id_rsa.pub user@raspberrypi  # Replace 'user@raspberrypi' with your Raspberry Pi's user and hostname/IP
```

### On the Raspberry Pi, edit the SSH configuration to disable password authentication:
```bash
sudo sed -i '/PasswordAuthentication yes/c\PasswordAuthentication no' /etc/ssh/sshd_config
sudo service ssh restart
```

### Verification:
Ensure SSH key-based login works and password login does not by trying to SSH into the Raspberry Pi.

## 11. Secure Network Services: Using Non-Standard Ports

### Edit the SSH configuration to change the default port:
```bash
sudo sed -i '/#Port 22/a\Port 2222' /etc/ssh/sshd_config  # This example changes the SSH port to 2222
sudo service ssh restart
```

### Verification:
Attempt to SSH using the new port to ensure it's working. Use the command `ssh -p 2222 user@raspberrypi`, replacing `2222` with your chosen port and `user@raspberrypi` with your actual username and hostname/IP.

## 12. Install PortSentry to Detect and Respond to Port Scans

### Install PortSentry:
```bash
sudo apt install portsentry
```

### Configure PortSentry for advanced mode:
```bash
sudo sed -i 's/TCP_MODE="tcp"/TCP_MODE="atcp"/' /etc/portsentry/portsentry.conf
sudo sed -i 's/UDP_MODE="udp"/UDP_MODE="audp"/' /etc/portsentry/portsentry.conf
sudo service portsentry restart
```

### Verification:
Check PortSentry status and logs to ensure it's monitoring and responding to port scans. Use `sudo service portsentry status` and review the logs in `/var/log/portsentry/portsentry.log`.

## 13. Implement Rate Limiting on Login Attempts

### Install necessary PAM module for rate limiting:
```bash
sudo apt-get install libpam-modules-bin
```

### Edit PAM SSH configuration to introduce delay after failed attempts:
```bash
echo "auth required pam_tally2.so onerr=fail deny=5 unlock_time=900" | sudo tee -a /etc/pam.d/sshd
sudo service ssh restart
```

### Verification:
Attempt incorrect logins to trigger the delay, ensuring the system enforces a timeout after the specified number of failed attempts.

## 14. Disable Unnecessary Components

### If not needed, disable wireless connectivity:
```bash
sudo rfkill block wifi
sudo rfkill block bluetooth
```

### Disable GPIO if not needed:
```bash
echo "blacklist gpio" | sudo tee -a /etc/modprobe.d/raspi-blacklist.conf
```

### Verification:
Check that wireless interfaces and GPIO are not accessible. Use `ifconfig` to verify that wireless interfaces are disabled and attempt to access GPIO to confirm it's blocked.

## 15. Read-Only Filesystem for Critical Components

### Make /boot read-only:
```bash
sudo mount -o remount,ro /boot
```

### For a more permanent solution, edit /etc/fstab to mount /boot as read-only:
```bash
sudo sed -i '/ \/boot / s/defaults/defaults,ro/' /etc/fstab
```

### Verification:
Attempt to modify files in /boot to ensure it's read-only. The system should prevent any changes.

## 16. Secure Boot Settings

### Ensure secure boot is enabled if supported by your Raspberry Pi model to prevent unauthorized boot sequences:
Note: Secure Boot setup can vary by model and firmware version. Refer to the official Raspberry Pi documentation for specific instructions for your model.

### Verification:
Check the firmware settings to confirm Secure Boot is enabled. This may involve accessing the Raspberry Pi's BIOS or UEFI settings during boot.

## 17. Encrypt Sensitive Data

### Install GnuPG for encryption:
```bash
sudo apt-get install gnupg
```

### To encrypt a file:
```bash
gpg -c filename  # Replace 'filename' with the name of the file you wish to encrypt
```

### To decrypt the file:
```bash
gpg filename.gpg  # Replace 'filename.gpg' with the name of your encrypted file
```

### Verification:
Ensure you can encrypt and decrypt files using GnuPG. Try opening the decrypted file to confirm the contents are intact.

## 18. Disable

 or Uninstall Unnecessary Packages

### List installed packages:
```bash
dpkg --list
```

### Remove unnecessary packages:
```bash
sudo apt-get remove --purge packagename  # Replace 'packagename' with the actual name of the package you wish to remove
```

### Optionally, clean up unused dependencies:
```bash
sudo apt-get autoremove
```

### Verification:
Ensure the system operates normally without the removed packages. Check disk space usage with `df -h` to confirm space has been freed up.


## 19. Additional Recommendations

### Configure Network Segmentation
If possible, segment your network to isolate the Raspberry Pi and reduce its exposure to unnecessary traffic.

### Implement Hardware Security Modules (HSM)
If your project involves sensitive cryptographic operations, consider using a Hardware Security Module for key management and cryptographic processing.

### Regularly Review Security Audits
Perform regular security audits using tools like Lynis to identify potential vulnerabilities and review security practices.
```

This complete guide provides a structured approach to securing and maintaining a Raspberry Pi or similar Unix/Linux system, covering everything from basic password changes and system updates to more advanced security measures like Fail2Ban, firewall setup, and encryption. Each step includes commands for making the changes and methods for verifying that the changes have been implemented successfully.
