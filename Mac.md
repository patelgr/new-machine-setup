# Mac OS Development Environment Setup

This guide walks you through setting up a development environment on Mac OS. It includes installing essential tools like Xcode Command Line Tools, Homebrew, Zsh, Oh My Zsh, Powerlevel10k theme, various utilities, and setting up Python environments.

## Prerequisites

Ensure your Mac OS is up to date to avoid any compatibility issues.

## Step 1: Install Xcode Command Line Tools

Xcode Command Line Tools are essential for development on Mac OS. Install them by running:

```sh
xcode-select --install
```

## Step 2: Configure SSH (Optional)

If you need to change the default SSH port:

1. Open the SSH config file in a text editor.
2. Find the line with `Port 22` and change it to your desired port, for example, `Port 20171`.

```sh
sudo nano /etc/ssh/sshd_config
```

After editing, restart the SSH service for the changes to take effect.

## Step 3: Install Homebrew

Homebrew is a package manager for Mac OS. Install it with the following command:

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

## Step 4: Install and Configure Zsh

Zsh is a powerful shell with more features and customizability than the default Bash.

1. Install Zsh using Homebrew:

   ```sh
   brew install zsh
   ```

2. Change your default shell to Zsh:

   ```sh
   chsh -s $(which zsh)
   ```

## Step 5: Install Oh My Zsh

Oh My Zsh is a framework for managing Zsh configuration. Install it with:

```sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
```

## Step 6: Install Powerlevel10k Theme

Powerlevel10k provides a fast and extensible prompt for Zsh.

1. Clone the Powerlevel10k repository:

   ```sh
   git clone https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k
   ```

2. Set Powerlevel10k as the default theme by modifying `~/.zshrc`:

   ```sh
   sed -i -e '/^[[:space:]]*ZSH_THEME=/ {s/^/# /; s/$/\nZSH_THEME="powerlevel10k/powerlevel10k"/}' ~/.zshrc
   ```

## Step 7: Install Utilities

Install some common utilities and applications using Homebrew:

```sh
# Install Iterm2, a replacement for Terminal
brew install --cask iterm2

# Install Textmate, a text editor
brew install --cask textmate

# Install fonts
brew tap homebrew/cask-fonts
brew install --cask font-fira-code-nerd-font

# Install Zsh plugins and other utilities
brew install zsh-autosuggestions zsh-syntax-highlighting z zsh-history-substring-search tree fzf

# Run the FZF install script
$(brew --prefix)/opt/fzf/install
```

## Step 8: Configure `.zshrc`

Customize your Zsh plugins in `~/.zshrc`. For example:

```sh
plugins=(git zsh-autosuggestions zsh-syntax-highlighting history common-aliases pyenv)

# Add more plugins as needed
```

## Step 9: Python Environment Setup

1. Install PyEnv to manage Python versions:

   ```sh
   brew install pyenv
   ```

2. Install a specific Python version, e.g., Python 3.9.13:

   ```sh
   pyenv install 3.9.13
   pyenv global 3.9.13
   ```

## Step 10: Install Browsers

Install your preferred browsers using Homebrew:

```sh
brew install --cask google-chrome firefox microsoft-edge brave-browser
```

## Step 11: Install and Configure Java (Optional)

1. Install OpenJDK versions:

   ```sh
   brew install openjdk@11 openjdk@17
   ```

2. Configure Java environments:

   ```sh
   # Add aliases to switch between Java versions in `~/.zshrc`
   alias java11="export JAVA_HOME=\$(/usr/libexec/java_home -v 11); java -version"
   alias java17="export JAVA_HOME=\$(/usr/libexec/java_home

 -v 17); java -version"
   ```

## Additional Configurations

- **Vim Configuration**: Create a `.vimrc` file in your home directory for Vim customizations, such as enabling syntax highlighting.

  ```sh
  echo "syntax on\ncolorscheme desert" > ~/.vimrc
  ```

- **Environment Variables**: Set environment variables for compilers and tools as needed, for example:

  ```sh
  export LDFLAGS="-L/usr/local/opt/zlib/lib -L/usr/local/opt/sqlite/lib -L/usr/local/opt/bzip2/lib"
  export CPPFLAGS="-I/usr/local/opt/zlib/include -I/usr/local/opt/sqlite/include -I/usr/local/opt/bzip2/include"
  ```

## Conclusion

Restart your terminal or execute `exec zsh` for the changes to take effect. You now have a powerful development environment set up on your Mac OS, complete with Zsh, Oh My Zsh, Powerlevel10k, and essential development tools. Customize further as needed to suit your workflow.
