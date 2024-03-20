#### NAME
**firesec** - A comprehensive firewall security management tool.

#### SYNOPSIS
```plaintext
firesec COMMAND [OPTIONS]... [ARGUMENTS]...
```

#### DESCRIPTION
`firesec` is designed to streamline the management of firewall rules, making it easier for administrators to configure, test, and manage network traffic policies. It provides a suite of commands to add, remove, test, and check firewall rules, apply profiles for common use cases, manage firewall rule backups and restorations, and list firewall rules in a structured format.

#### COMMANDS
- **`service-allow SERVICE-NAME`**
  Automatically creates allow rules for a known service by applying rules for the standard ports used by the service.
  
- **`service-deny SERVICE-NAME`**
  Removes allow rules associated with a given service.

- **`test-rule 'RULE-DETAILS' --duration DURATION`**
  Temporarily applies a rule for a specified duration, with an automatic rollback unless confirmed.

- **`apply-profile PROFILE-NAME`**
  Applies a set of predefined rules based on the chosen profile.

- **`undo`**
  Reverts to the previous set of rules before the last command was applied.

- **`backup FILE-PATH`**
  Backs up the current firewall rules to a specified file.

- **`restore FILE-PATH`**
  Restores firewall rules from a specified backup file.

- **`wizard`**
  Starts an interactive setup wizard to guide the user through configuring firewall rules.

- **`allow-add PROTOCOL PORT [INTERFACE]`**
  Adds a rule to allow traffic for a specific port and protocol, optionally on a specified interface.

- **`allow-remove PROTOCOL PORT [INTERFACE]`**
  Removes an allow rule for a specific port and protocol, optionally on a specified interface.

- **`block-add PROTOCOL PORT [INTERFACE]`**
  Adds a rule to block traffic for a specific port and protocol, optionally on a specified interface.

- **`block-remove PROTOCOL PORT [INTERFACE]`**
  Removes a block rule for a specific port and protocol, optionally on a specified interface.

- **`check-rules PROTOCOL PORT [INTERFACE]`**
  Checks if a specific port and protocol are allowed or blocked by the firewall, optionally on a specified interface.

- **`check-services`**
  Compares running services with firewall rules to identify any active services that may be missing corresponding allow rules.

- **`list [OPTIONS]`**
  Displays firewall rules in a tabular format. Can list all rules or filter based on specified criteria such as port, protocol, and interface.

#### OPTIONS for the `list` Command
- **`--port PORT`**: Optional. Specifies the port to filter the list of firewall rules.
- **`--protocol PROTOCOL`**: Optional. Specifies the protocol to filter the list of firewall rules (e.g., TCP, UDP).
- **`--interface INTERFACE`**: Optional. Specifies the interface to filter the list of firewall rules.
- **`--allowed`**: Optional. Filters the list to show only allowed rules.
- **`--blocked`**: Optional. Filters the list to show only blocked rules.

#### EXAMPLES for the `list` Command
1. **Listing All Firewall Rules:**
   ```plaintext
   firesec list
   ```

2. **Listing Firewall Rules for TCP Protocol:**
   ```plaintext
   firesec list --protocol tcp
   ```

3. **Listing Allowed Rules for Port 80:**
   ```plaintext
   firesec list --port 80 --allowed
   ```

4. **Listing Blocked Rules on eth0 Interface:**
   ```plaintext
   firesec list --interface eth0 --blocked
   ```

5. **Listing Firewall Rules for UDP Protocol on Port 53:**
   ```plaintext
   firesec list --protocol udp --port 53
   ```

#### SAMPLE OUTPUT for the `list` Command
```plaintext
| STATUS    | PROTOCOL | PORT | INTERFACE |
|-----------|----------|------|-----------|
| Allowed   | TCP      | 80   | eth0      |
| Blocked   | TCP      | 22   | eth0      |
| Allowed   | UDP      | 53   | eth1      |
```

This table format provides a clear and organized view of the firewall rules, making it easy for users to understand the current configurations and filter the rules as needed.

#### SEE ALSO
iptables(8), netstat(8), ss(8), iptables-persistent(8)
