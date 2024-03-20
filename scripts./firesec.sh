#!/bin/bash

log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}



undo() {
    log_message "Undo functionality not implemented."
}

service_allow() {
    local service_name="$1"
    log_message "Service allow functionality not implemented."
}

service_deny() {
    local service_name="$1"
    log_message "Service deny functionality not implemented."
}

test_rule() {
    local rule_details="$1"
    local duration="$2"
    log_message "Test rule functionality not implemented."
}

apply_profile() {
    local profile_name="$1"
    log_message "Apply profile functionality not implemented."
}

undo() {
    log_message "Undo functionality not implemented."
}

backup() {
    local file_path="$1"
    log_message "Backup functionality not implemented."
}

restore() {
    local file_path="$1"
    log_message "Restore functionality not implemented."
}

wizard() {
    log_message "Wizard functionality not implemented."
}

block_add() {
    local protocol="$1"
    local port="$2"
    local interface="$3"
    log_message "Block add functionality not implemented."
}

block_remove() {
    local protocol="$1"
    local port="$2"
    local interface="$3"
    log_message "Block remove functionality not implemented."
}

check_rules() {
    local protocol="$1"
    local port="$2"
    local interface="$3"
    log_message "Check rules functionality not implemented."
}

check_services() {
    log_message "Check services functionality not implemented."
}

list_rules() {
    local port="$1"
    local protocol="$2"
    local interface="$3"
    local allowed="$4"
    local blocked="$5"

    # Start building the iptables command
    local cmd="sudo iptables -L -v -n"

    # Check and append protocol if specified
    if [ -n "$protocol" ]; then
        cmd+=" -p $protocol"
    fi

    # Execute the command and start filtering
    local output=$($cmd | tail -n +3) # Skip the first two header lines

    # Filter by interface, if specified
    if [ -n "$interface" ]; then
        output=$(echo "$output" | grep " $interface ")
    fi

    # Filter by port, if specified
    if [ -n "$port" ]; then
        output=$(echo "$output" | grep "dpt:$port\|spt:$port")
    fi

    # Filter by rule action (ACCEPT for allowed, REJECT/DROP for blocked)
    if [ -n "$allowed" ]; then
        output=$(echo "$output" | grep "ACCEPT")
    elif [ -n "$blocked" ]; then
        output=$(echo "$output" | grep -E "REJECT|DROP")
    fi

    # Format and display the output
    echo "| STATUS    | PROTOCOL | PORT | INTERFACE |"
    echo "|-----------|----------|------|-----------|"
    echo "$output" | awk '{ printf("| %-9s | %-8s | %-4s | %-9s |\n", $NF, $4, $11, $8) }'
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
    local valid_interface=0
    local interfaces=($(ip link show | awk -F: '$0 !~ "lo|^[^0-9]"{print $2;getline}' | tr -d ' ')) # Creates an array of available interfaces

    while [[ $valid_interface -eq 0 ]]; do
        if [[ -z "$interface" ]]; then
            echo "Available interfaces:"
            printf "%s\n" "${interfaces[@]}"
            echo "* for all interfaces or leave blank for default (all interfaces)"
            read -p "Enter interface: " interface
        fi

        # Check if interface is in the array of valid interfaces or if it's a special case
        if [[ " ${interfaces[*]} " =~ " ${interface} " || "$interface" == "*" || -z "$interface" ]]; then
            valid_interface=1
        else
            echo "Invalid interface. Please choose from the list above."
            interface=""  # Reset interface to trigger the prompt again
        fi
    done

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

