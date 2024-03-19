#!/bin/bash

# Load configuration parameters# Configuration File for Security Setup Script

# Log file configuration
LOG_FILE="/var/log/security_setup.log"

# Custom Ports to Always Allow
# Format: "protocol:port" (e.g., "tcp:80" for HTTP)
# Add additional lines for more ports as needed
CUSTOM_PORTS=(
    "tcp:80"    # HTTP
    "tcp:443"   # HTTPS
    "tcp:21"    # FTP
)

# Fail2Ban Configuration
# Path to Fail2Ban Jail Configuration (Optional)
FAIL2BAN_JAIL_CONF="/etc/fail2ban/jail.local"

# Custom Fail2Ban Settings
# Specify settings as "setting=value"
# Example: "bantime=3600"
FAIL2BAN_SETTINGS=(
    "bantime=3600"
    "findtime=600"
    "maxretry=5"
)

# Network tools preference
# If you prefer 'netstat' over 'ss', set this to 'netstat' or vice versa.
PREFERRED_NET_TOOL="netstat"

# Configuration file for security setup script

# Log file path
LOG_FILE="/var/log/security_setup.log"

# Specific ports to always allow (space-separated)
ALWAYS_ALLOW_PORTS="80 443"

# Custom Fail2Ban settings (as needed)
FAIL2BAN_SETTINGS="..."


# Log function
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | sudo tee -a "$LOG_FILE" >&2
}

# Update and upgrade system packages
updateSystem() {
    log_message "Updating system packages..."
    sudo apt update && sudo apt upgrade -y || {
        log_message "Failed to update packages"; exit 1;
    }
}

# Function to add firewall rules idempotently
add_firewall_rule() {
    local protocol=$1
    local port=$2
    local rule="-A INPUT -p $protocol --dport $port -j ACCEPT"

    if ! sudo iptables -C INPUT -p "$protocol" --dport "$port" -j ACCEPT 2>/dev/null; then
        log_message "Allowing $protocol connections on port $port..."
        sudo iptables $rule
    else
        log_message "$protocol rule for port $port already exists, skipping..."
    fi
}

# Firewall configuration
configureFirewall() {
    # Allow SSH and other predefined ports
    for port in 22 $ALWAYS_ALLOW_PORTS; do
        add_firewall_rule "tcp" "$port"
    done

    # Automatically allow ports for running services
    if command -v netstat >/dev/null; then
        log_message "Using netstat to list listening ports..."
        LISTENING_PORTS=$(sudo netstat -tuln | grep LISTEN)
    elif command -v ss >/dev/null; then
        log_message "Using ss to list listening ports..."
        LISTENING_PORTS=$(sudo ss -tuln | grep LISTEN)
    else
        log_message "Neither netstat nor ss is installed. Please install one of these tools."
        exit 1
    fi

    while read -r line; do
        protocol=$(echo "$line" | awk '{print $1}')
        port=$(echo "$line" | awk '{print $4}' | cut -d: -f2)
        [ -n "$port" ] && add_firewall_rule "$protocol" "$port"
    done <<< "$LISTENING_PORTS"
}

# Install essential packages
installPackages() {
    log_message "Installing iptables and fail2ban..."
    sudo apt install iptables iptables-persistent fail2ban -y || {
        log_message "Failed to install required packages"; exit 1;
    }
}

# Save iptables rules with error handling
saveIptablesRules() {
    log_message "Saving iptables rules..."
    sudo netfilter-persistent save || {
        log_message "Failed to save iptables rules"; exit 1;
    }
}

# Rollback function
rollback() {
    log_message "Rolling back changes..."
    # Rollback implementation
}

# Main script execution
main() {
    updateSystem
    configureFirewall
    installPackages
    saveIptablesRules
    # More functions as needed
    log_message "Script execution completed."
}

# Check for -y flag to bypass prompts
if [ "$1" == "-y" ] || [ "$1" == "--yes" ]; then
    main
else
    read -p "Proceed with script execution? (Y/n): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] && main
fi

