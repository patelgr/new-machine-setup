## Linux Development Environment Setup with Ruby

### Prerequisites

- Ensure your system is up to date.
- Verify `sudo` or root access.

### Step 1: System Update

Keep your system packages fresh to avoid any compatibility issues.

```bash
sudo apt-get update && sudo apt-get full-upgrade -y
```

### Step 2: Install Essential Packages

Before diving into specific language environments, ensure you have the essential build tools.

```bash
sudo apt-get install -y build-essential curl file git
```

### Step 3: Install and Configure Ruby with rbenv

`rbenv` is a lightweight Ruby version management tool.

1. Install `rbenv` and `ruby-build`:

    ```bash
    sudo apt-get update && sudo apt-get install -y rbenv ruby-build
    ```

2. Integrate `rbenv` into your shell:

    ```bash
    echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >>~/.bashrc
    echo 'eval "$(rbenv init -)"' >>~/.bashrc
    source ~/.bashrc
    ```

3. Install Ruby versions:

    ```bash
    rbenv install 3.1.4  # Install Ruby 3.1.4
    rbenv global 3.1.4  # Set it as the default version
    ```

4. Verify the Ruby installation:

    ```bash
    ruby -v
    ```

### Step 4: Install Zsh

Switch to a more advanced shell for an enhanced terminal experience.

```bash
sudo apt-get install zsh -y
chsh -s $(which zsh)
```

### Step 5: Install Oh My Zsh

Enhance your Zsh experience with this community-driven framework.

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
```

### Step 6: Install Powerlevel10k Theme

Give your terminal a modern look with Powerlevel10k.

```bash
git clone https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k
sed -i -e '/^[[:space:]]*ZSH_THEME=/ {s/^/# /; s/$/\nZSH_THEME="powerlevel10k/powerlevel10k"/}' ~/.zshrc
```

### Step 7: Install Homebrew for Linux

Now that Ruby is set up, install Homebrew to manage additional packages.

1. Install Homebrew:

    ```bash
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    ```

2. Add Homebrew to your PATH:

    ```bash
    echo 'eval $($(brew --prefix)/bin/brew shellenv)' >>~/.bashrc
    source ~/.bashrc
    ```

3. Verify the installation:

    ```bash
    brew doctor
    ```

### Step 8: Install Zsh Plugins

Boost your shell productivity with these plugins.

```bash
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```

### Step 9: Clean Up

Remove unnecessary packages and clean temporary files.

```bash
sudo apt-get autoremove -y && sudo apt-get autoclean -y
```

### Conclusion

Restart your terminal or run `exec zsh` to apply the changes. Your Linux development environment is now set up with Ruby, Zsh, Oh My Zsh, Powerlevel10k, and Homebrew, providing a solid foundation for various development tasks. Customize further as needed to fit your workflow.
