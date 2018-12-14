#!/bin/bash

# This script is meant to copy local changes to git

CONFIG="$HOME/vps-setup/config"

copy_sshd_config(){
  SSHD_PATH="/etc/ssh/sshd_config"
  cp "$SSHD_PATH" "$CONFIG"
}


#tmux
copy_tmux(){
  TMUX_RC="$HOME/.tmux.conf"
  cp "$TMUX_RC" "$CONFIG"
}
# vim
copy_vim(){
  VIM_RC="$HOME/.vimrc"
  cp "$VIM_RC" "$CONFIG"
}

copy_zsh(){
  ZSH_RC="$HOME/.zshrc"

  if [[ "$OSTYPE" == "linux-gnu"]]; then
    cp "$ZSH_RC" "$CONFIG"
  else
    cp "$ZSH_RC" "$CONFIG/cygwin_zshrc"
  fi
}

copy_mintty(){
  if [[ "$OSTYPE" == "cygwin" ]]; then
    MINTTY_RC="$HOME/.minttyrc"
    cp "$MINTTY_RC" "$CONFIG"
  fi
}

copy_pryrc(){
  PRYRC="$HOME/.pryrc"
  cp "$PRYRC" "$CONFIG"
}
