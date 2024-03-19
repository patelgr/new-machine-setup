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
        undo)
            undoIptablesChanges
            ;;
        *)
            echo "Usage: $0 {update|allow|remove|configure|undo} [protocol] [port]"
            exit 1
            ;;
    esac
    log_message "Operation completed."
}

main "$@"
