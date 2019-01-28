#!/bin/bash

if [[ `id -u` == 0 ]]; then 
  echo "Do not run this as sudo / root. Rerun this script." 1>&2
  exit 1
fi

# to pass all command line arguments use
# "$@"
run(){
  if [[ $OSTYPE == 'linux-gnu' ]]; then
    linux_prereqs
  elif [[ $OSTYPE == 'cygwin' ]]; then
    apt-cyg install ruby
    apt-cyg install gnupg2 # allows gpg -v 2.1>
    apt-cyg install make gcc-core gcc-g++ libcrypt-devel # ruby dependencies
    gem install bundler
  fi

  bundle install

  rake make # add parameters with thor

  # This sources either ~/.zshenv or ~/.bash_profile depending on the value 
  # of $SHELL , currently only supports zsh and bash
  restart_shell

  # Currently logs in for git & heroku
  rake login
}

# Nice little bundle of apt_setup, setting the ruby version & sourcing the chruby script
linux_prereqs(){
  apt_setup 

  install_chruby_and_ruby

  # This will update profile
  make_chruby_usable

  install_gems
}

# This will do a few things:
# It will run update, upgrade & dist-upgrade. dist-upgrade will upgrade the 
# ubuntu distro.
# Additionally, it will fetch the inital packages needed prior to running 
# the Rakefile
apt_setup(){
  sudo apt-get update
  sudo apt-get upgrade -y
  yes "\n" | sudo apt-get dist-upgrade -y

  LIBS="software-properties-common gnupg2 less ufw ack-grep libfuse2 apt-transport-https ca-certificates build-essential bison zlib1g-dev libyaml-dev libssl-dev libgdbm-dev libreadline-dev libffi-dev fuse make gcc ruby"

  for lib in $LIBS; do
    sudo apt-get install $lib -y
  done

  sudo apt-get update
}

# This installs ruby & chruby under the .tmp folder within the repo
install_chruby_and_ruby(){
  mkdir -p .tmp
  cd .tmp
  install_ruby
  install_chruby
  cd ..
}

install_ruby(){
  wget -O ruby-install-0.7.0.tar.gz https://github.com/postmodern/ruby-install/archive/v0.7.0.tar.gz .tmp
  tar -xzvf ruby-install-0.7.0.tar.gz
  cd ruby-install-0.7.0
  sudo make install

  ruby-install --latest ruby --no-reinstall
  cd ..
}

install_chruby(){
  wget -O chruby-0.3.9.tar.gz https://github.com/postmodern/chruby/archive/v0.3.9.tar.gz
  tar -xzvf chruby-0.3.9.tar.gz
  cd chruby-0.3.9
  sudo ./scripts/setup.sh
  cd ..
}

add_chruby_to_profile_d(){
  dirname="/etc/profile.d"
  filename="$dirname/chruby.sh"

  mkdir -p $dirname

  add_chruby="if [ -n "\$BASH_VERSION" ] || [ -n "\$ZSH_VERSION" ]; then
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

# Will create an empty .bash_profile or .zshenv so that it can be source
# Creation of the profile only happens if the file is not detected in the
# homedir && depending on the value of $SHELL
restart_shell(){
  if [[ "$SHELL" == '/bin/bash' ]]; then
    if [[ ! -e "~/.bash_profile" ]]; then
      touch "~/.bash_profile"
    fi
    source ~/.bash_profile
  elif [[ "$SHELL" == '/bin/zsh' ]]; then
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

install_gems(){
  GEMS="bundler colorls neovim rake pry"
  for item in $GEMS; do
    gem install $item
  done
}

run
