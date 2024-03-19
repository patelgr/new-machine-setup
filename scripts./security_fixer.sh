#!/bin/bash

# Update and upgrade packages
sudo apt update && sudo apt upgrade -y

# Install iptables and iptables-persistent for firewall management
sudo apt install iptables iptables-persistent -y

# Allow SSH and custom port
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 20171 -j ACCEPT

# Save iptables rules
sudo netfilter-persistent save

# Install fail2ban for additional security
sudo apt install fail2ban -y
