#!/bin/bash

# Configuration
LOG_FILE="/var/log/security_setup.log"
ALWAYS_ALLOW_PORTS="22 80 443"
PREFERRED_NET_TOOL="netstat"
IPTABLES_BACKUP_DIR="/var/backups/iptables"
CURRENT_IPTABLES_BACKUP="$IPTABLES_BACKUP_DIR/current_rules.bak"
PREVIOUS_IPTABLES_BACKUP="$IPTABLES_BACKUP_DIR/previous_rules.bak"

# Ensure the backup directory exists
mkdir -p "$IPTABLES_BACKUP_DIR"

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

# Backup current iptables rules
backupIptablesRules() {
    log_message "Backing up current iptables rules..."
    if [ -f "$CURRENT_IPTABLES_BACKUP" ]; then
        # Move current backup to "previous" to allow for undo functionality
        sudo mv "$CURRENT_IPTABLES_BACKUP" "$PREVIOUS_IPTABLES_BACKUP"
    fi
    sudo iptables-save > "$CURRENT_IPTABLES_BACKUP"
}

# Restore iptables rules from the previous backup
undoIptablesChanges() {
    if [ -f "$PREVIOUS_IPTABLES_BACKUP" ]; then
        log_message "Restoring iptables rules from the previous backup..."
        sudo iptables-restore < "$PREVIOUS_IPTABLES_BACKUP"
        # Swap the backups, making the previous state the new current state
        sudo mv "$PREVIOUS_IPTABLES_BACKUP" "$CURRENT_IPTABLES_BACKUP"
        saveIptablesRules
    else
        log_message "No previous iptables backup found. Cannot undo."
    fi
}

# Save iptables rules
saveIptablesRules() {
    log_message "Saving iptables rules..."
    sudo netfilter-persistent save || {
        log_message "Failed to save iptables rules"; exit 1;
    }
}

# Add, remove, and configure firewall rules with backup and undo capabilities
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

configureFirewall() {
    log_message "Configuring firewall with basic settings..."
    for port in $ALWAYS_ALLOW_PORTS; do
        allowFirewallRule "tcp" "$port"
    done
}

# Function to list current iptables rules for a specific protocol
listCurrentIptablesRules() {
    local protocol=$1
    sudo iptables -S | grep -E "^-A INPUT" | grep -m 1 -E " -p $protocol " | awk '{print $9}' | cut -d ':' -f2
}

# Function to compare listening ports with iptables rules
comparePortsAndFirewall() {
    local listening_ports
    local current_rules
    local protocol
    local port

    # Determine the network tool to use (prefer netstat, fall back to ss)
    local net_tool=""
    if command -v $PREFERRED_NET_TOOL >/dev/null; then
        net_tool=$PREFERRED_NET_TOOL
    elif [ "$PREFERRED_NET_TOOL" = "netstat" ] && command -v ss >/dev/null; then
        net_tool="ss"
    else
        log_message "Neither netstat nor ss is installed. Please install one of these tools."
        exit 1
    fi

    # Use the determined network tool to get listening ports
    if [ "$net_tool" = "netstat" ]; then
        listening_ports=$(sudo netstat -tuln | grep LISTEN | awk '{print $1 " " $4}' | cut -d: -f1,2)
    else
        listening_ports=$(sudo ss -tuln | grep LISTEN | awk '{print $1 " " $5}' | cut -d: -f1,2)
    fi

    # Get current iptables rules for TCP and UDP
    local tcp_rules=$(listCurrentIptablesRules "tcp")
    local udp_rules=$(listCurrentIptablesRules "udp")

    # Compare listening ports against iptables rules
    while IFS= read -r line; do
        protocol=$(echo "$line" | awk '{print $1}')
        port=$(echo "$line" | awk '{print $2}' | cut -d':' -f2)

        if [ "$protocol" = "tcp" ] && ! echo "$tcp_rules" | grep -q -w "$port"; then
            echo "Missing iptables rule for TCP port $port. Suggested command:"
            echo "allowFirewallRule tcp $port"
        elif [ "$protocol" = "udp" ] && ! echo "$udp_rules" | grep -q -w "$port"; then
            echo "Missing iptables rule for UDP port $port. Suggested command:"
            echo "allowFirewallRule udp $port"
        fi
    done <<< "$listening_ports"
}

# Check for missing firewall configurations and suggest commands to add them
checkMissingFirewallConfigs() {
    log_message "Checking for missing firewall configurations..."
    local listening_ports
    local protocol
    local port

    # Determine the preferred network tool and use it to list listening ports
    if [ "$PREFERRED_NET_TOOL" = "netstat" ] && command -v netstat >/dev/null; then
        listening_ports=$(netstat -tuln | awk '/^tcp/{sub(".*:", "", $4); print $1":"$4}')
    elif [ "$PREFERRED_NET_TOOL" = "ss" ] && command -v ss >/dev/null; then
        listening_ports=$(ss -tuln | awk '/^tcp/{sub(".*:", "", $4); print $1":"$4}')
    else
        log_message "Preferred network tool ($PREFERRED_NET_TOOL) is not available."
        return 1
    fi

    # Check each listening port against iptables rules
    for entry in $listening_ports; do
        protocol=$(echo "$entry" | cut -d: -f1)
        port=$(echo "$entry" | cut -d: -f2)

        if [ "$protocol" = "tcp" ] && ! sudo iptables -C INPUT -p tcp --dport "$port" -j ACCEPT 2>/dev/null; then
            log_message "Missing firewall rule for $protocol on port $port. To allow, run: ./script.sh allow $protocol $port"
        fi
    done
}

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
        undo)
            undoIptablesChanges
            ;;
        check)
            checkMissingFirewallConfigs
            ;;
        *)
            echo "Usage: $0 {update|allow|remove|configure|undo|check} [protocol] [port]"
            exit 1
            ;;
    esac
    log_message "Operation completed."
}

main "$@"


