#!/bin/bash

# ADDED -f to remove symlinks

source "$HOME/vps-setup/install_zsh.sh"
#tmux
copy_tmux(){
    TMUX_ORIG="$HOME/.tmux.conf.orig"
    TMUX_RC="$HOME/.tmux.conf"
    if [[ ! -e "$TMUX_ORIG" ]]; then
        echo "copying your current $TMUX_RC file to $TMUX_ORIG"
        cp -f ~/.tmux.conf ~/.tmux.conf.orig
    else
        echo "$TMUX_ORIG" already exists. No original .tmux.conf copy will be made.
    fi
    cp -f ~/vps-setup/config/tmux.conf "$TMUX_RC"
}
# vim
copy_vim(){
    VIM_ORIG="$HOME/.vimrc.orig"
    VIM_RC="$HOME/.vimrc"
    DOTVIM="$HOME/.vim"
    if [[ ! -e "$DOTVIM" ]]; then
        echo "$DOTVIM not found. Creating a $DOTVIM directory. Please check vim is on this machine."
        mkdir -p "$DOTVIM"
    fi

    if [[ ! -e "$VIM_ORIG" ]]; then
        echo "copying $VIM_RC to $VIM_ORIG"
        cp -f "$VIM_RC" "$VIM_ORIG"
    else
        echo "$VIM_ORIG already exists. No original .vimrc copy will be made."
    fi
    cp -f ~/vps-setup/config/vimrc "$VIM_RC"
}
# neovim
copy_neovim(){
    NVIM_PATH="$HOME/.config/nvim"
    if [[ ! -e "$NVIM_PATH" ]]; then
        mkdir -p "$NVIM_PATH"
    fi
   
    if [[ ! -e "$HOME/.local/share/nvim/site/autoload" ]]; then
        mkdir -p "$HOME/.local/share/nvim/site/autoload"
    fi 
    cp -f "$HOME/.vim" "$NVIM_PATH"
    cp -f "$HOME/.vim/autoload" "$SITE/autoload"
    cp -f "$HOME/vps-setup/config/vimrc" "$NVIM_PATH/init.vim"
}

copy_zsh(){
    ZSH_ORIG="$HOME/.zshrc.orig"
    ZSH_RC="$HOME/.zshrc"

    if [[ ! -e "$ZSH_ORIG" ]]; then
        echo "copying $ZSH_RC to $ZSH_ORIG"
        cp -f "$ZSH_RC" "$ZSH_ORIG"
    else
        echo "$ZSH_ORIG detected. No original copy of .zshrc will be made"
    fi

    if [[ $OSTYPE == 'linux-gnu' ]]; then
        #zsh
        echo "#$OSTYPE detected. Installing ZSH intended for $OSTYPE"
        cp -f ~/vps-setup/config/zshrc "$ZSH_RC"
    fi

    if [[ $OSTYPE == 'cygwin' ]]; then
        echo "$OSTYPE detected. Installed ZSH intended for $OSTYPE"
        cp -f ~/vps-setup/config/cygwin_zshrc "$ZSH_RC"
    fi
}

copy_mintty(){
   
    if [[ $OSTYPE == 'cygwin' ]]; then
        echo "$OSTYPE detected. Symlinking .minttyrc"
   
        MINTTY_ORIG="$HOME/.minttyrc.orig"
        MINTTY_RC="$HOME/.minttyrc"
    
        if [[ ! -e "$MINTTY_ORIG" ]]; then
            echo "No $MINTTY_ORIG detected. Creating a copy of .minttyrc at $MINTTY_ORIG"
            cp -f "$MINTTY_RC" "$MINTTY_ORIG"
        else
            echo "$MINTTY_ORIG already exists. No original copy will be made"
        fi

        cp -f ~/vps-setup/config/minttyrc "$MINTTY_RC"
    else
        echo 'No need to install mintty! Youre not using cygwin / babun!'
    fi
}

copy_pryrc(){
  PRYRC="$HOME/.pryrc"
  if [[ -e "$PRYRC" ]]; then
    if [[ ! -e "$PRYRC.orig" ]]; then
      echo "creating pryrc backup @ $PRYRC.orig"
      cp -f "$PRYRC" "$PRYRC.orig"
    else
      echo "$PRYRC.orig already exists. No backup created"
    fi
  fi
  cp -f ~/vps-setup/config/pryrc "$PRYRC"
}

add_dejavu_sans_mono_font(){
  if [[ $OSTYPE == 'linux-gnu' ]]; then
    mkdir -p ~/.local/share/fonts
    cd ~/.local/share/fonts && curl -fLo "DejaVu Sans Mono for Powerline Nerd Font Complete.otf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/DejaVuSansMono/Regular/complete/DejaVu%20Sans%20Mono%20Nerd%20Font%20Complete%20Mono.ttf
  fi
}

add_personal_snippets(){
  if [[ ! -e "$HOME/ParamagicianUltiSnips" ]]; then
    git clone https://github.com/ParamagicDev/ParamagicianUltiSnips.git "$HOME/ParamagicianUltiSnips"
  else
    cd "$HOME/ParamagicianUltiSnips"
    git pull
    cd ~
  fi
}


echo 'copying tmux'
copy_tmux
echo 'copying vim'
copy_vim
echo 'copying neovim'
copy_neovim
echo 'copying zsh'
copy_zsh
echo 'copying mintty.'
copy_mintty
echo 'copying pryrc'
copy_pryrc
echo 'Adding dejavu sans mono font'
add_dejavu_sans_mono_font
echo 'Adding paramagician ultisnips'
add_personal_snippets

echo 'dotfiles transferred successfully!'
