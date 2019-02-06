#!/bin/bash

BIN="$HOME/bin"
VPS_CLI="$PWD/lib/vps_cli.rb"

main(){
  check_if_root
  add_to_bin
  linux_prereqs

  # sources chruby
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
  if [[ `id -u` == 0 ]]; then 
    echo "Do not run this as sudo / root. Rerun this script." 1>&2
    exit 1
  fi
}

make_executable(){
  chmod +x "$VPS_CLI" || sudo chmod +x "$VPS_CLI"
}

# nice little bundle of apt_setup, setting the ruby version & sourcing the chruby script
linux_prereqs(){
  apt_setup
  install_chruby_and_ruby
  # this will update profile
  make_chruby_usable
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
    sudo apt-get install $lib -y
  done

  sudo apt-get update
}

# this installs ruby & chruby under the .tmp folder within the repo
install_chruby_and_ruby(){
  mkdir -p .tmp
  cd .tmp
  install_ruby
  install_chruby
  cd ..
}

install_ruby(){
  wget -o ruby-install-0.7.0.tar.gz https://github.com/postmodern/ruby-install/archive/v0.7.0.tar.gz .tmp
  tar -xzvf ruby-install-0.7.0.tar.gz
  cd ruby-install-0.7.0
  sudo make install

  ruby-install --latest ruby --no-reinstall
  cd ..
}

install_chruby(){
  wget -o chruby-0.3.9.tar.gz https://github.com/postmodern/chruby/archive/v0.3.9.tar.gz
  tar -xzvf chruby-0.3.9.tar.gz
  cd chruby-0.3.9
  sudo ./scripts/setup.sh
  cd ..
}

add_chruby_to_profile_d(){
  dirname="/etc/profile.d"
  filename="$dirname/chruby.sh"

  mkdir -p $dirname

  add_chruby="if [ -n "\$bash_version" ] || [ -n "\$zsh_version" ]; then
  source /usr/local/share/chruby/chruby.sh
  source /usr/local/share/chruby/auto.sh
fi" 

  if [[ $(! grep -q "$add_chruby" "$filename") ]]; then
    echo "$add_chruby" | sudo tee -a "$filename"
  else
    echo "chruby already added"	
  fi
}

set_ruby_version(){
  chruby ruby latest
}

# will create an empty .bash_profile or .zshenv so that it can be source
# creation of the profile only happens if the file is not detected in the
# homedir && depending on the value of $shell
restart_shell(){
  if [[ "$shell" == '/bin/bash' ]]; then
    if [[ ! -e "~/.bash_profile" ]]; then
      touch "~/.bash_profile"
    fi
    source ~/.bash_profile
  elif [[ "$shell" == '/bin/zsh' ]]; then
    if [[ ! -e ~/.zshenv ]]; then
      touch ~/.zshenv
    fi
    source ~/.zshenv
  fi
}

make_chruby_usable(){
  add_chruby_to_profile_d                      
  set_ruby_version                             
  restart_shell                                
}

# install_gems(){
#   gems="bundler colorls neovim rake pry"
#   for item in $gems; do
#     gem install $item
#   done
# }

