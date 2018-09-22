#!/bin/bash

# Install zsh and accompanying plugins

# checks if ohmyzsh already installed
install_oh_my_zsh() {
    if [[ ! -e "$HOME/.oh-my-zsh" ]]; then
        git clone https://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh
        chsh -s /bin/zsh
    else
        echo "ohmyzsh already installed"
    fi
}

ZSH_PLUGINS="$HOME/.oh-my-zsh/custom/plugins"

install_zsh_autosuggestions() {
    #checks if autosuggestions exists
    if [[ ! -e "$ZSH_PLUGINS/zsh-autosuggestions" ]]; then
        git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_PLUGINS/zsh-autosuggestions"
    else
        echo 'zsh-autosuggestions already exists'
    fi
}

install_zsh_syntax_highlighting() {
    # check if syntax highlighting already installed
    if [[ ! -e "$ZSH_PLUGINS/zsh-syntax-highlighting" ]]; then
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_PLUGINS/zsh-syntax-highlighting"
    else
        echo 'zsh-syntax-highlighting already exists'
    fi
}

install_oh_my_zsh
install_zsh_syntax_highlighting
install_zsh_autosuggestions
echo 'zsh & plugins installed'
