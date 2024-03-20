#!/bin/bash

log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}


# Function definitions for each command
service_allow() {
    local service_name="$1"
    # Add logic to create allow rules for the service
}

service_deny() {
    local service_name="$1"
    # Add logic to remove allow rules for the service
}

test_rule() {
    local rule_details="$1"
    local duration="$2"
    # Add logic to temporarily apply a rule
}

apply_profile() {
    local profile_name="$1"
    # Add logic to apply a predefined set of rules
}

undo() {
    # Add logic to revert to the previous set of rules
}

backup() {
    local file_path="$1"
    # Add logic to back up current firewall rules
}

restore() {
    local file_path="$1"
    # Add logic to restore firewall rules from a backup
}

wizard() {
    # Add logic for interactive setup wizard
}

# Function to check if required commands are installed
check_required_commands() {
    if ! command -v iptables &> /dev/null; then
        echo "iptables could not be found, please install it to proceed."
        exit 1
    fi

    if ! command -v ip &> /dev/null; then
        echo "ip command could not be found, please install it to proceed."
        exit 1
    fi
}

# Function to validate and prompt for protocol
prompt_for_protocol() {
    local protocol=$1
    while [[ "$protocol" != "tcp" && "$protocol" != "udp" ]]; do
        echo "Valid protocols are tcp or udp."
        read -p "Enter protocol (tcp/udp): " protocol
    done
    echo $protocol
}

# Function to validate and prompt for port
prompt_for_port() {
    local port=$1
    while ! [[ "$port" =~ ^[0-9]+$ ]]; do
        read -p "Enter port (must be an integer): " port
    done
    echo $port
}

# Function to list and select network interface
prompt_for_interface() {
    local interface=$1
    if [[ -z "$interface" ]]; then
        echo "Available interfaces:"
        ip link show | awk -F: '$0 !~ "lo|^[^0-9]"{print $2;getline}' # Lists network interfaces
        echo "* for all interfaces or leave blank for default (all interfaces)"
        read -p "Enter interface: " interface
    fi
    if [[ -n "$interface" && "$interface" != "*" ]]; then
        interface_option="-i $interface"
    else
        interface_option=""
    fi
    echo $interface_option
}

common_check_and_prompt() {
    check_required_commands

    local protocol=$(prompt_for_protocol "$1")
    local port=$(prompt_for_port "$2")
    local interface_option=$(prompt_for_interface "$3")

    echo "$protocol" "$port" "$interface_option"
}

allow_add() {
    read protocol port interface_option <<< $(common_check_and_prompt "$1" "$2" "$3")

    if ! sudo iptables -C INPUT -p "$protocol" --dport "$port" $interface_option -j ACCEPT 2>/dev/null; then
        log_message "Allowing $protocol connections on port $port $interface_option..."
        sudo iptables -A INPUT -p "$protocol" --dport "$port" $interface_option -j ACCEPT
    else
        log_message "$protocol rule for port $port $interface_option already exists, skipping..."
    fi
}

allow_remove() {
    read protocol port interface_option <<< $(common_check_and_prompt "$1" "$2" "$3")

    if sudo iptables -C INPUT -p "$protocol" --dport "$port" $interface_option -j ACCEPT 2>/dev/null; then
        log_message "Removing $protocol connections on port $port $interface_option..."
        sudo iptables -D INPUT -p "$protocol" --dport "$port" $interface_option -j ACCEPT
    else
        log_message "$protocol rule for port $port $interface_option does not exist, skipping..."
    fi
}

block_add() {
    local protocol="$1"
    local port="$2"
    local interface="$3"
    # Add logic to block traffic for a specific protocol and port
}

block_remove() {
    local protocol="$1"
    local port="$2"
    local interface="$3"
    # Add logic to remove a block rule
}

check_rules() {
    local protocol="$1"
    local port="$2"
    local interface="$3"
    # Add logic to check if a port and protocol are allowed or blocked
}

check_services() {
    # Add logic to compare running services with firewall rules
}

list_rules() {
    local port="$1"
    local protocol="$2"
    local interface="$3"
    local allowed="$4"
    local blocked="$5"
    # Add logic to list firewall rules, possibly filtering by port, protocol, interface, allowed, or blocked
}

# Main function to parse and execute commands
main() {
    case "$1" in
        service-allow)
            service_allow "$2"
            ;;
        service-deny)
            service_deny "$2"
            ;;
        test-rule)
            shift 1 # Remove the first argument, which is the command name
            test_rule "$@"
            ;;
        apply-profile)
            apply_profile "$2"
            ;;
        undo)
            undo
            ;;
        backup)
            backup "$2"
            ;;
        restore)
            restore "$2"
            ;;
        wizard)
            wizard
            ;;
        allow-add)
            allow_add "$2" "$3" "$4"
            ;;
        allow-remove)
            allow_remove "$2" "$3" "$4"
            ;;
        block-add)
            block_add "$2" "$3" "$4"
            ;;
        block-remove)
            block_remove "$2" "$3" "$4"
            ;;
        check-rules)
            check_rules "$2" "$3" "$4"
            ;;
        check-services)
            check_services
            ;;
        list)
            shift 1 # Remove 'list' command to handle options
            list_rules "$@"
            ;;
        *)
            echo "Usage: $0 {command} [options]"
            exit 1
            ;;
    esac
    log_message "Operation completed."
}

main "$@"

