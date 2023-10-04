#!/bin/bash

# Function to log messages
log() {
    echo "[LOG] $1"
}

# Function to backup configuration files
backup_config_files() {
    current_datetime=$(date +'%Y-%m-%d_%H-%M-%S')
    backup_dir=~/.bkp/config/$current_datetime
    mkdir -p "$backup_dir"
    cp ~/.zshrc "$backup_dir/zshrc_backup" && log "Backed up ~/.zshrc to $backup_dir/zshrc_backup"
    cp ~/.vimrc "$backup_dir/vimrc_backup" && log "Backed up ~/.vimrc to $backup_dir/vimrc_backup"
    log "Configuration files backed up to $backup_dir."
}

# Function to install a package using Homebrew (macOS)
install_package_mac() {
    local package_name="$1"
    if [[ -x "$(command -v brew)" ]]; then
        # Homebrew is installed, install the package
        brew update
        brew install "$package_name"
    else
        log "Homebrew is not installed. Cannot install '$package_name'."
    fi
}

# Function to install a package using apt (Debian-based Linux)
install_package_debian() {
    local package_name="$1"
    sudo apt-get install -y "$package_name"
}

# Function to install a package based on the platform
install_package() {
    local package_name="$1"

    if [[ $(uname) == "Darwin" ]]; then
        install_package_mac "$package_name"
    elif [[ -f /etc/debian_version ]]; then
        install_package_debian "$package_name"
    else
        log "Unsupported operating system for package installation."
    fi
}

# Function to install Java on macOS using Homebrew
install_java_mac() {
    local version="$1"
    log "Installing Java $version on macOS..."

    # Install openjdk using install_package function
    install_package "openjdk@$version"

    echo "alias java$version=\"export JAVA_HOME=\$(/usr/libexec/java_home -v $version); java -version\"" >> ~/.zshrc && log "Added Java $version alias to ~/.zshrc"
    sudo ln -sfn "/usr/local/opt/openjdk@$version/libexec/openjdk.jdk" "/Library/Java/JavaVirtualMachines/openjdk-$version.jdk"
    log "Java $version installation completed."
}

# Function to install Java on Linux (Debian-based)
install_java_debian() {
    local version="$1"
    log "Installing Java $version on Debian-based Linux..."

    # Install openjdk using install_package function
    install_package "openjdk-$version-jdk"

    log "Java $version installation completed."
}

# Function to install Java based on OS and version
install_java() {
    local version="$1"
    if [[ $(uname) == "Darwin" ]]; then
        # Install openjdk using install_package function
        install_java_mac "$version"
    elif [[ -f /etc/debian_version ]]; then
        # Install openjdk using install_package function
        install_java_debian "$version"
    else
        log "Unsupported operating system for Java installation."
    fi
}

# Function to install Oh-My-Zsh
install_oh_my_zsh() {
    log "Installing Oh-My-Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
    log "Oh-My-Zsh installation completed."
}

# Function to download and install Powerlevel10k theme
install_powerlevel10k() {
    local theme_dir="${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k"
    log "Downloading and installing Powerlevel10k theme..."
    git clone https://github.com/romkatv/powerlevel10k.git "$theme_dir" && log "Powerlevel10k theme installed to $theme_dir"
    sed -i -e '/^[[:space:]]*ZSH_THEME=/ {s/^/# /; s/$/\nZSH_THEME="powerlevel10k\/powerlevel10k"/}' ~/.zshrc && log "Updated ~/.zshrc with Powerlevel10k theme"
}

# Function to install a Zsh plugin
install_zsh_plugin() {
    local plugin_repo="$1"
    local zsh_custom="${ZSH_CUSTOM:-~/.oh-my-zsh/custom}"
    local plugin_name=$(basename "$plugin_repo")
    local plugin_dir="$zsh_custom/plugins/$plugin_name"

    if [ -d "$plugin_dir" ]; then
        log "$plugin_name is already installed."
        return
    fi

    git clone "https://github.com/$plugin_repo" "$plugin_dir" && log "Installed $plugin_name plugin to $plugin_dir"
}

# Function to configure Zsh plugins
configure_zsh_plugins() {
    local zsh_custom="${ZSH_CUSTOM:-~/.oh-my-zsh/custom}"

    # List of plugins to install
    local plugins=(
        "zsh-users/zsh-autosuggestions"
        "zsh-users/zsh-syntax-highlighting"
    )

    log "Configuring Zsh plugins..."

    for plugin_repo in "${plugins[@]}"; do
        install_zsh_plugin "$plugin_repo"
    done

    # Define the list of plugins for the .zshrc file
    local plugin_list=(
        "brew"
        "git"
        "gradle"
        "ng"
        "npm"
        "yarn"
        "zsh-syntax-highlighting"
        "zsh-autosuggestions"
        "macOS"
        "history-substring-search"
        "history"
        "common-aliases"
        "pyenv"
        "jsontools"
        "zsh-interactive-cd"
    )

    # Modify Zsh plugins in ~/.zshrc
    sed -i -e '/^plugins=/ {
        /\)$/ {
            c\
    # Update the plugins list
    plugins=(
      '"${plugin_list[@]}"'
    )
        }
    }' ~/.zshrc && log "Updated ~/.zshrc with new plugin list"
}

# Function to configure Zsh plugins if Oh-My-Zsh is installed
configure_oh_my_zsh_plugins() {
    local zsh_custom="${ZSH_CUSTOM:-~/.oh-my-zsh/custom}"

    if [[ -d "$zsh_custom" ]]; then
        configure_zsh_plugins
    else
        log "Oh-My-Zsh is not installed. Skipping Zsh plugin configuration."
    fi
}

# Function to check if PyEnv is installed
check_pyenv() {
    if [ -x "$(command -v pyenv)" ]; then
        return 0  # PyEnv is installed
    else
        return 1  # PyEnv is not installed
    fi
}

# Function to install Python 3.9.13 with PyEnv
install_python_3_9_13() {
    if check_pyenv; then
        # Install and set Python version with PyEnv
        pyenv install 3.9.13
        if [ $? -eq 0 ]; then
            pyenv global 3.9.13
            log "Python 3.9.13 installed and set as the global version."
        else
            log "Error installing Python 3.9.13 with PyEnv."
        fi
    else
        log "PyEnv is not installed. Please install PyEnv first."
    fi
}


# Function to install PyEnv and its dependencies
install_pyenv() {
    if [[ $(uname) == "Darwin" ]]; then
        # Install required packages on macOS using Homebrew
        install_package_mac openssl readline sqlite3 xz zlib
        install_package_mac pyenv
        log "PyEnv installation completed."
    elif [[ $(uname) == "Linux" ]]; then
        # Install required packages on Linux using apt
        sudo apt update
        sudo apt install -y git openssl libssl-dev libbz2-dev libreadline-dev libsqlite3-dev libffi-dev
        curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash
        log "PyEnv installation completed."
    else
        log "Unsupported operating system."
        exit 1
    fi
}

# Function to install Fira Code Nerd Font if specified
install_firacode() {
    if [[ $(uname) == "Darwin" ]]; then
        # Install Fira Code Nerd Font on macOS
        install_package "font-fira-code-nerd-font"
    elif [[ -f /etc/debian_version ]]; then
        # Install Fira Code Nerd Font on Debian-based Linux
        sudo apt-get install fonts-firacode
    else
        log "Unsupported operating system for Fira Code Nerd Font installation."
    fi
}

# Function to install TextMate using Homebrew
install_textmate() {
    install_package_mac textmate
}

# Function to install Xcode Command Line Tools
install_xcode_tools() {
    xcode-select --install
}

# Function to install Homebrew
install_homebrew() {
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    brew analytics off
}

# Function to install iTerm2 using Homebrew
install_iterm2() {
    install_package_mac iterm2
}

# Function to install web browsers using Homebrew
# Function to install web browsers using Homebrew
install_web_browsers() {
    local browsers=(
        "google-chrome"
        "firefox"
        "microsoft-edge"
        "brave-browser"
    )

    for browser in "${browsers[@]}"; do
        install_package_mac "$browser"
    done
}

# Function to install Rectangle (window manager) using Homebrew
install_rectangle() {
    install_package_mac rectangle
}

# Function to tap into Homebrew Cask Fonts
tap_fonts() {
    brew tap homebrew/cask-fonts
}


# Function to install Zsh on Debian-based Linux
install_zsh_debian() {
    if [[ -x "$(command -v zsh)" ]]; then
        log "Zsh is already installed."
    else
        sudo apt-get update
        sudo apt-get install -y zsh
        log "Zsh installed successfully."
    fi
}

# Function to install additional packages on Debian-based Linux
run_deb_update() {
    # Update and upgrade packages
    sudo apt update
    sudo apt upgrade

    # Tap into Fonts repository (not exactly Homebrew Cask Fonts, but similar)
    sudo add-apt-repository universe
    sudo apt-get update
}

# Function to install additional packages on Debian-based Linux
install_debian_zsh_helper_packages() {
    sudo apt install git
    sudo apt-get install zsh-history-substring-search
    sudo apt-get install zsh-syntax-highlighting
    sudo apt-get install zsh
    sudo apt-get install z
    sudo apt-get install tree
}

# Check if Zsh is the default shell
install_and_make_default_and_configure_zsh() {
    current_shell="$(basename "$SHELL")"
    if [ "$current_shell" != "zsh" ]; then
        # Check if Zsh is installed
        if ! command -v zsh &> /dev/null; then
            log "Zsh is not installed. Installing Zsh..."
            install_zsh_debian
        fi

        # Change the default shell to Zsh
        chsh -s /bin/zsh
        if [ $? -eq 0 ]; then
            log "Zsh is now the default shell."
            log "Installing omz."
            install_oh_my_zsh
            log "Installing Powerlevel10k."
            install_powerlevel10k
            log "Configuring zsh plugins."
            configure_oh_my_zsh_plugins  # Call to configure Zsh plugins if Oh-My-Zsh is installed
        else
            log "Error changing the default shell to Zsh. You can manually change it later using 'chsh -s /bin/zsh'."
        fi
    fi
}

# Main function
main() {
    if [[ $(uname) == "Darwin" ]]; then
        install_xcode_tools
        install_homebrew
        install_iterm2
        install_web_browsers
        install_rectangle
        install_textmate
        tap_fonts
        install_firacode  # Call the function to install Fira Code Nerd Font
    elif [[ $(uname) == "Linux" ]]; then
        run_deb_update
        install_firacode
        install_debian_zsh_helper_packages
    else
        log "Unsupported operating system."
    fi
    backup_config_files
    install_and_make_default_and_configure_zsh
    install_java 11
    install_java 17
    install_pyenv
    install_python_3_9_13
    backup_config_files
    log "Installation completed."
}

# Execute the main function
main
