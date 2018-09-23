#!/bin/bash

source "$HOME/vps-setup/install_zsh.sh"
#tmux
symlink_tmux(){
    TMUX_ORIG="$HOME/.tmux.conf.orig"
    TMUX_RC="$HOME/.tmux.conf"
    if [[ ! -e "$TMUX_ORIG" ]]; then
        echo "copying your current $TMUX_RC file to $TMUX_ORIG"
        cp ~/.tmux.conf ~/.tmux.conf.orig
    else
        echo "$TMUX_ORIG" already exists. No original .tmux.conf copy will be made.
    fi
    ln -f -s ~/vps-setup/tmux.conf "$TMUX_RC"
}
# vim
symlink_vim(){
    VIM_ORIG="$HOME/.vimrc.orig"
    VIM_RC="$HOME/.vimrc"
    DOTVIM="$HOME/.vim"
    if [[ ! -e "$DOTVIM" ]]; then
        echo "$DOTVIM not found. Creating a $DOTVIM directory. Please check vim is on this machine."
        mkdir -p "$DOTVIM"
    fi

    if [[ ! -e "$VIM_ORIG" ]]; then
        echo "copying $VIM_RC to $VIM_ORIG"
        cp "$VIM_RC" "$VIM_ORIG"
    else
        echo "$VIM_ORIG already exists. No original .vimrc copy will be made."
    fi
    ln -f -s ~/vps-setup/vimrc "$VIM_RC"
}
# neovim
symlink_neovim(){
NVIM_PATH="/home/$USER/.config/nvim"
    if [[ ! -e "$NVIM_PATH" ]]; then
        mkdir -p "$NVIM_PATH/init.vim"
        mkdir -p "$NVIM_PATH/autoload"
        ln -f -s ~/.vim "$NVIM_PATH"
        ln -f -s ~/.vimrc "$NVIM_PATH/init.vim"
    fi

    ln -f -s ~/vps-setup/vimrc "$NVIM_PATH/init.vim"
}

symlink_zsh(){
    ZSH_ORIG="$HOME/.zshrc.orig"
    ZSH_RC="$HOME/.zshrc"

    if [[ ! -e "$ZSH_ORIG" ]]; then
        echo "copying $ZSH_RC to $ZSH_ORIG"
        cp "$ZSH_RC" "$ZSH_ORIG"
    else
        echo "$ZSH_ORIG detected. No original copy of .zshrc will be made"
    fi

    if [[ $OSTYPE == 'linux-gnu' ]]; then
        #zsh
        echo "#$OSTYPE detected. Installing ZSH intended for $OSTYPE"
        ln -f -s ~/vps-setup/zshrc "$ZSH_RC"
    fi

    if [[ $OSTYPE == 'cygwin' ]]; then
        echo "$OSTYPE detected. Installed ZSH intended for $OSTYPE"
        ln -f -s ~/vps-setup/cygwin_zshrc "$ZSH_RC"
    fi
}

symlink_mintty(){
   
    if [[ $OSTYPE == 'cygwin' ]]; then
        echo "$OSTYPE detected. Symlinking .minttyrc"
   
        MINTTY_ORIG="$HOME/.minttyrc.orig"
        MINTTY_RC="$HOME/.minttyrc"
    
        if [[ ! -e "$MINTTY_ORIG" ]]; then
            echo "No $MINTTY_ORIG detected. Creating a copy of .minttyrc at $MINTTY_ORIG"
            cp "$MINTTY_RC" "$MINTTY_ORIG"
        else
            echo "$MINTTY_ORIG already exists. No original copy will be made"
        fi

        ln -f -s ~/vps-setup/minttyrc "$MINTTY_RC"
    else
        echo 'No need to install mintty! Youre not using cygwin / babun!'
    fi
}

echo 'symlinking tmux'
symlink_tmux
echo 'symlinking vim'
symlink_vim
echo 'symlinking neovim'
symlink_neovim
echo 'symlinking zsh'
symlink_zsh
echo 'symlinking mintty w/ zenburn colorscheme and inconsolata nerdfont.'
symlink_mintty

echo 'dotfiles transferred successfully!'
