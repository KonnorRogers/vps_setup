#!/bin/bash


BIN="$HOME/bin"
VPS_CLI="$PWD/exe/vps-cli"

main(){
  # will error if running as root
  check_if_root

  # symlinks /vps_cli/exe/vps-cli to $HOME/bin
  add_to_bin

  # runs through the varios sudo apt installs required prior to
  # installs
  apt_setup

  # installs chruby & ruby-install
  install_chruby_and_ruby

  # adds chruby to the appropriate files
  make_chruby_usable

  # sources zshrc or bashrc depending on what is being used
  restart_shell

  gem install bundler
  bundle install
}

add_to_bin(){
  make_executable
  mkdir -p "$BIN"
  symlink_vps_cli
  export PATH="$PATH:$BIN"
}

symlink_vps_cli(){
  ln -fs "$VPS_CLI" "$BIN/vps-cli"
}

check_if_root(){
  if [[ $(id -u) == 0 ]]; then 
    echo "Do not run this as sudo / root. Rerun this script." 1>&2
    exit 1
  fi
}

make_executable(){
  chmod +x "$VPS_CLI" || sudo chmod +x "$VPS_CLI"
}

# this will do a few things:
# it will run update, upgrade & dist-upgrade. dist-upgrade will upgrade the 
# ubuntu distro.
# additionally, it will fetch the inital packages needed prior to running 
# the rakefile
apt_setup(){
  sudo apt-get update
  sudo apt-get upgrade -y
  yes "\n" | sudo apt-get dist-upgrade -y

  libs="software-properties-common gnupg2 less ufw ack-grep libfuse2 apt-transport-https ca-certificates build-essential bison zlib1g-dev libyaml-dev libssl-dev libgdbm-dev libreadline-dev libffi-dev fuse make gcc ruby"

  for lib in $libs; do
    sudo apt-get install "$lib" -y
  done

  sudo apt-get update
  sudo apt-get autoremove -y
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

  cd "$RUBY_INSTALL_DIR" || exit 2
  sudo make install

  ruby-install --latest ruby --no-reinstall
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
set_ruby_version(){
  source_chruby="source /usr/local/share/chruby/chruby.sh
  source /usr/local/share/chruby/auto.sh"
  file="$1"

  if ! grep -q "^$source_chruby$" "$file"; then
    echo "$source_chruby" >> "$file"
  fi

  current_ruby_version="ruby-2.6.2"
  ruby_version="$HOME/.ruby-version"
  if [[ -e "$ruby_version" ]]; then
    touch "$ruby_version" 
  fi

  if ! grep -q "^$current_ruby_version$" "$ruby_version"; then
    echo "$current_ruby_version" >> "$ruby_version" 
  fi
}

# will create an empty .bashrc or .zshrc so that it can be source
# creation of the profile only happens if the file is not detected in the
# homedir && depending on the value of $SHELL

restart_shell(){
  if [[ "$SHELL" == *"bash" ]]; then
    BASH_RC="$HOME/.bashrc"

    if [[ ! -e "$BASH_RC" ]]; then
      touch "$BASH_RC"
    fi

    set_ruby_version "$BASH_RC"

    source "$BASH_RC"

  elif [[ "$SHELL" == *"zsh" ]]; then
    ZSHRC="$HOME/.zshrc"

    if [[ ! -e "$ZSHRC" ]]; then
      touch "$ZSHRC"
    fi

    set_ruby_version "$ZSHRC"
    source "$ZSHRC"

  else
    echo "Make sure to set your chruby version by adding"
    echo "add 'chruby ruby latest' to your *.rc file"
  fi
}

make_chruby_usable(){
  add_chruby_to_profile_d                      
  restart_shell                                
}

# runs the main method
main
