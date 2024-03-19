#!/bin/bash

# Prompt for changing default passwords (Manual step recommended)
echo "It is highly recommended to change default user passwords now."
echo "Press Enter to continue to the next step..."
read -p ""

# Secure SSH
# Disable root login over SSH by modifying /etc/ssh/sshd_config
sudo sed -i '/^PermitRootLogin/s/yes/no/' /etc/ssh/sshd_config
sudo service ssh restart

# Disable default user passwords (root and dietpi in this case)
sudo passwd -l root
sudo passwd -l dietpi
