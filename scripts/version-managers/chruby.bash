#!/bin/bash

RUBY_VERSION="2.6.2"

main(){
  # installs chruby & ruby-install
  install_chruby_and_ruby

  # adds chruby to the appropriate files
  make_chruby_usable
}

# this installs ruby & chruby under the .tmp folder within the repo
install_chruby_and_ruby(){
  temp_dir=".tmp"
  mkdir -p "$temp_dir"
  cd "$temp_dir" || exit 2
  install_ruby
  install_chruby
  cd ..
  rm -rf "$temp_dir"
}

install_ruby(){
  RUBY_INSTALL_TAR="ruby-install-0.7.0.tar.gz"
  RUBY_INSTALL_DIR="ruby-install-0.7.0/"

  if [[ ! -e "$RUBY_INSTALL_TAR" ]]; then
    wget -O "$RUBY_INSTALL_TAR" https://github.com/postmodern/ruby-install/archive/v0.7.0.tar.gz
  fi

  if [[ ! -e "$RUBY_INSTALL_DIR" ]]; then
    tar -xzvf "$RUBY_INSTALL_TAR"
  fi

  echo "$PWD"
  tar -xzvf "$RUBY_INSTALL_TAR"
  cd "$RUBY_INSTALL_DIR" || exit 2
  sudo make install
  ruby-install ruby "$RUBY_VERSION" --no-reinstall
  cd ..
}

install_chruby(){
  CHRUBY_TAR="chruby-0.3.9.tar.gz"
  CHRUBY_DIR="chruby-0.3.9"
  if [[ ! -e "$CHRUBY_TAR" ]]; then
    wget -O "$CHRUBY_TAR" https://github.com/postmodern/chruby/archive/v0.3.9.tar.gz
  fi

  if [[ ! -e "$CHRUBY_DIR" ]]; then
    tar -xzvf "$CHRUBY_TAR"
  fi

  cd "$CHRUBY_DIR" || exit 2
  sudo ./scripts/setup.sh
  cd ..
}

# Appends chruby to /etc/profile.d for use by bash / zsh
# This allows use system wide
add_chruby_to_profile_d(){
  dirname="/etc/profile.d"
  filename="$dirname/chruby.sh"

  mkdir -p "$dirname"

  add_chruby="if [ -n \"\$BASH_VERSION\" ] || [ -n \"\$ZSH_VERSION\" ]; then
  source /usr/local/share/chruby/chruby.sh
  source /usr/local/share/chruby/auto.sh
fi" 

  if ! grep -q "$add_chruby" "$filename"; then
    echo "$add_chruby" | sudo tee -a "$filename"
  else
    echo "chruby already added"	
  fi
}

# Accepts a file as a parameter
# If the file does not contain the string "chruby ruby latest"
# Then append it to the end of the file
add_chruby_to_file(){
  source_chruby="source /usr/local/share/chruby/chruby.sh
  source /usr/local/share/chruby/auto.sh"
  file="$1"

  if ! grep -q "^$source_chruby$" "$file"; then
    echo "$source_chruby" >> "$file"
  fi
}

# will create an empty .bashrc or .zshrc so that it can be source
# creation of the profile only happens if the file is not detected in the
# homedir && depending on the value of $SHELL
add_to_rc_file(){
  if [[ "$SHELL" == *"bash" ]]; then
    BASH_RC="$HOME/.bashrc"

    if [[ ! -e "$BASH_RC" ]]; then
      touch "$BASH_RC"
    fi
    add_chruby_to_file "$BASH_RC"

  elif [[ "$SHELL" == *"zsh" ]]; then
    ZSHRC="$HOME/.zshrc"
    if [[ ! -e "$ZSHRC" ]]; then
      touch "$ZSHRC"
    fi
    add_chruby_to_file "$ZSHRC"

  else
    echo "Make sure to set your chruby version by adding"
    echo "'chruby ruby-2.*.*' to your *.rc file"
  fi
}

make_chruby_usable(){
  add_chruby_to_profile_d                      
  add_to_rc_file
  source "../restart_shell.bash"
  chruby ruby-"$RUBY_VERSION"
}

main
