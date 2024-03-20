#!/bin/bash

log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}


# Function to check if required commands are installed
check_required_commands() {
    # Check for iptables command
    if ! command -v iptables &> /dev/null; then
        echo "The iptables command could not be found or is not accessible."
        echo "Please ensure iptables is installed and try running this script with sudo:"
        echo "sudo $0" # $0 is a special variable that contains the name of the script being executed
        exit 1
    fi

    if ! command -v ip &> /dev/null; then
        echo "ip command could not be found, please install it to proceed."
        exit 1
    fi
}


check_default_policy() {
    local default_policy=$(sudo iptables -L INPUT --line-numbers -n | grep "Chain INPUT" | awk '{print $4}')
    if [ "$default_policy" == "ACCEPT" ]; then
        echo "ACCEPT"
    else
        echo "DROP"
    fi
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

wizard() {
    log_message "Wizard functionality not implemented."
}

backup() {
    local file_path="$1"
    if [ -z "$file_path" ]; then
        log_message "No backup file path provided."
        return 1
    fi

    log_message "Backing up iptables rules to '$file_path'."
    sudo iptables-save > "$file_path"
    if [ $? -eq 0 ]; then
        log_message "Backup successful."
    else
        log_message "Backup failed."
        return 1
    fi
}


restore() {
    local file_path="$1"
    local temp_backup="/tmp/iptables.backup.$(date +%Y%m%d%H%M%S)"

    if [ ! -f "$file_path" ]; then
        log_message "Backup file '$file_path' not found."
        return 1
    fi

    # Create a temporary backup of the current rules
    log_message "Creating temporary backup of current iptables rules."
    sudo iptables-save > "$temp_backup"
    if [ $? -ne 0 ]; then
        log_message "Failed to create temporary backup. Aborting restore."
        return 1
    fi

    # Attempt to restore from the specified backup file
    log_message "Restoring iptables rules from '$file_path'."
    sudo iptables-restore < "$file_path"
    if [ $? -eq 0 ]; then
        log_message "Restore successful."
        # Clean up temporary backup file after successful restore
        rm -f "$temp_backup"
    else
        log_message "Restore failed. Attempting to revert to temporary backup."
        # If restore fails, revert to the temporary backup
        if sudo iptables-restore < "$temp_backup"; then
            log_message "Revert to temporary backup successful."
        else
            log_message "Critical error: Revert to temporary backup failed."
        fi
        # Consider keeping the temporary backup in case of critical failure for manual inspection
    fi
}



block_add() {
    read protocol port interface_option <<< $(common_check_and_prompt "$1" "$2" "$3")
    local default_policy=$(check_default_policy)

    if [ "$default_policy" == "DROP" ]; then
        log_message "Default policy is DROP. Adding a block rule may have no effect."
        return 1
    fi

    if ! sudo iptables -C INPUT -p "$protocol" --dport "$port" $interface_option -j DROP 2>/dev/null; then
        log_message "Blocking $protocol traffic on port $port $interface_option..."
        sudo iptables -A INPUT -p "$protocol" --dport "$port" $interface_option -j DROP
    else
        log_message "Block rule for $protocol on port $port $interface_option already exists, skipping..."
    fi
}

block_remove() {
    read protocol port interface_option <<< $(common_check_and_prompt "$1" "$2" "$3")

    if sudo iptables -C INPUT -p "$protocol" --dport "$port" $interface_option -j DROP 2>/dev/null; then
        log_message "Removing block for $protocol traffic on port $port $interface_option..."
        sudo iptables -D INPUT -p "$protocol" --dport "$port" $interface_option -j DROP
    else
        log_message "Block rule for $protocol on port $port $interface_option does not exist, skipping..."
    fi
}


list_rules() {
    check_required_commands
    # Default chains
    local chains=("INPUT" "FORWARD" "OUTPUT")
    local specified_port="$1" # Optional first argument to specify a port
    local specified_chains=("$@") # All arguments as an array
    if [ "${#specified_chains[@]}" -gt 1 ]; then
        chains=("${specified_chains[@]:1}") # Use user-specified chains, if any
    fi

    echo "| # | CHAIN   | TARGET  | PROTOCOL | IN IFACE | OUT IFACE | SOURCE         | DESTINATION    | PORT  |PKTS  | bytes|"
    echo "|---|---------|---------|----------|----------|-----------|----------------|----------------|-------|------|------|"

    for chain in "${chains[@]}"; do
        # Checking if iptables command can be executed successfully for the current chain
        if ! sudo iptables -L "$chain" -n >/dev/null 2>&1; then
            echo "Error: Failed to list iptables rules for chain '$chain'. Skipping..."
            continue
        fi

        # Get default policy for the chain, remove parentheses
        local default_policy=$(sudo iptables -L "$chain" -n | head -n 1 | awk '{print $NF}' | tr -d ')')

        # Display default policy as the first 'rule' for the chain
        printf "| %-1s | %-7s | %-7s | %-8s | %-8s | %-9s | %-14s | %-14s | %-5s |%-5s | %-4s |\n" "*" "$chain" "$default_policy" "N/A" "N/A" "N/A" "N/A" "N/A" "N/A"
        
        # Get rules for the current chain
        local rules=$(sudo iptables -L "$chain" -v -n --line-numbers)
        
        # Process each rule
        while IFS= read -r line; do
            local line_number=$(echo "$line" | awk '{print $1}')
            local target=$(echo "$line" | awk '{print $4}')
            local prot=$(echo "$line" | awk '{print $5}')
            local in_iface=$(echo "$line" | awk '{print $7}')
            local out_iface=$(echo "$line" | awk '{print $8}')
            local source=$(echo "$line" | awk '{print $9}')
            local destination=$(echo "$line" | awk '{print $10}')
            local extra_info=$(echo "$line" | awk '{$1=$2=$3=$4=$5=$6=$7=$8=$9=""; print $0}')
            local port=$(echo "$extra_info" | grep -oE 'dpt:[0-9]+' | cut -d':' -f2)
            local pkts=$(echo "$line" | awk '{print $1}')
            local bytes=$(echo "$line" | awk '{print $2}')
            
            if [[ "$prot" == "0" ]]; then
                prot="All"
            elif [[ "$prot" == "6" ]]; then
                prot="TCP"
            elif [[ "$prot" == "17" ]]; then
                prot="UDP"
            fi

            # If a port is specified by the user, only display rules related to that port
            if [[ -n "$specified_port" && "$port" != "$specified_port" ]]; then
                continue
            fi

            if [[ "$line_number" =~ ^[0-9]+$ ]]; then
                printf "| %-1s | %-7s | %-7s | %-8s | %-8s | %-9s | %-14s | %-14s | %-5s |%-5s | %-4s |\n" "$line_number" "$chain" "$target" "$prot" "$in_iface" "$out_iface" "$source" "$destination" "$port" "$pkts" "$bytes"
            fi
        done <<< "$(echo "$rules" | tail -n +3)" # Skip the header lines for each chain
    done

    log_message "Listed iptables rules."
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

