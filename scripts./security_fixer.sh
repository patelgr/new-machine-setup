#!/bin/bash

# Configuration
LOG_FILE="/var/log/security_setup.log"
ALWAYS_ALLOW_PORTS="22 80 443"
PREFERRED_NET_TOOL="netstat"

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

# Add firewall rule
allowFirewallRule() {
    local protocol=$1
    local port=$2
    if ! sudo iptables -C INPUT -p "$protocol" --dport "$port" -j ACCEPT 2>/dev/null; then
        log_message "Allowing $protocol connections on port $port..."
        sudo iptables -A INPUT -p "$protocol" --dport "$port" -j ACCEPT
        saveIptablesRules
    else
        log_message "$protocol rule for port $port already exists, skipping..."
    fi
}

# Remove firewall rule
removeFirewallRule() {
    local protocol=$1
    local port=$2
    if sudo iptables -C INPUT -p "$protocol" --dport "$port" -j ACCEPT 2>/dev/null; then
        log_message "Removing $protocol connections on port $port..."
        sudo iptables -D INPUT -p "$protocol" --dport "$port" -j ACCEPT
        saveIptablesRules
    else
        log_message "$protocol rule for port $port does not exist, skipping..."
    fi
}

# Save iptables rules
saveIptablesRules() {
    log_message "Saving iptables rules..."
    sudo netfilter-persistent save || {
        log_message "Failed to save iptables rules"; exit 1;
    }
}

# Configure firewall with basic settings
configureFirewall() {
    log_message "Configuring firewall with basic settings..."
    for port in $ALWAYS_ALLOW_PORTS; do
        allowFirewallRule "tcp" "$port"
    done
}

# Install required packages
installPackages() {
    log_message "Installing iptables and fail2ban..."
    sudo apt install iptables iptables-persistent fail2ban -y || {
        log_message "Failed to install required packages"; exit 1;
    }
}

# Main execution logic
main() {
    case "$1" in
        update)
            updateSystem
            ;;
        allow)
            allowFirewallRule "$2" "$3"
            ;;
        remove)
            removeFirewallRule "$2" "$3"
            ;;
        configure)
            configureFirewall
            installPackages
            ;;
        *)
            echo "Usage: $0 {update|allow|remove|configure} [protocol] [port]"
            exit 1
            ;;
    esac
    log_message "Operation completed."
}

main "$@"
