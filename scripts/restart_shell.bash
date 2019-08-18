main(){
  if [[ "$SHELL" == *"bash" ]]; then
    BASH_RC="$HOME/.bashrc"

    if [[ ! -e "$BASH_RC" ]]; then
      touch "$BASH_RC"
    fi
    source "$BASH_RC"

  elif [[ "$SHELL" == *"zsh" ]]; then
    ZSHRC="$HOME/.zshrc"
    if [[ ! -e "$ZSHRC" ]]; then
      touch "$ZSHRC"
    fi
    source "$ZSHRC"
  else
    echo "Unable to source your *.rc file, only currently support bash / zsh"
    echo "Manually use NVM / PHPENV / CHRUBY"
  fi
}

main
