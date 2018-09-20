#!/bin/bash

#tmux
cp ~/.tmux.conf ~/.tmux.conf.orig
ln -f -s ~/vps-setup/tmux.conf ~/.tmux.conf
# vim
cp ~/.vimrc ~/.vimrc.orig
ln -f -s ~/vps-setup/vimrc ~/.vimrc
if [[ $OSTYPE == 'linux-gnu' ]]; then
    #zsh
    cp ~/.zshrc ~/.zshrc.orig
    ln -f -s ~/vps-setup/zshrc ~/.zshrc
    # neovim
    cp ~/.config/nvim/init.vim ~/.config/nvim/init.vim.orig
    ln -f -s ~/vps-setup/nvim/init.vim ~/.config/nvim/init.vim
fi

echo 'dotfiles transferred successfully!'
