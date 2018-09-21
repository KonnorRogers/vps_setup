#!/bin/bash
#tmux
cp ~/.tmux.conf ~/.tmux.conf.orig
ln -f -s ~/vps-setup/tmux.conf ~/.tmux.conf

# vim
cp ~/.vimrc ~/.vimrc.orig
ln -f -s ~/vps-setup/vimrc ~/.vimrc

# neovim
cp ~/.config/nvim/init.vim ~/.config/nvim/init.vim.orig

NVIM_PATH="/home/$USER/.config/nvim"
if [[ ! -e "$NVIM_PATH" ]]; then
    mkdir -p "$NVIM_PATH/init.vim"
fi

ln -f -s ~/vps-setup/vimrc ~/.config/nvim/init.vim
if [[ $OSTYPE == 'linux-gnu' ]]; then
    #zsh
    cp ~/.zshrc ~/.zshrc.orig
    ln -f -s ~/vps-setup/zshrc ~/.zshrc
fi

if [[ $OSTYPE == 'cygwin' ]]; then
    cp ~/.zshrc ~/.zshrc.orig
    ln -f -s ~/vps-setup/cygwin_zshrc ~/.zshrc
fi

echo 'dotfiles transferred successfully!'
