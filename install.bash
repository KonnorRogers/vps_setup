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
    pact install ruby || apt-cyg install ruby
    gem install bundler
  fi

  bundle install

  rake make
}

linux_prereqs(){
  apt_setup 
  
  mkdir -p .tmp
  cd .tmp

  install_ruby
  cd ..
  install_chruby
  cd ../..

  add_chruby_to_profile_d
  set_ruby_version
  install_gems
}

apt_setup(){
  sudo apt-get update
  sudo apt-get upgrade -y

  LIBS="software-properties-common gnupg2 less ufw ack-grep libfuse2 apt-transport-https ca-certificates build-essential bison zlib1g-dev libyaml-dev libssl-dev libgdbm-dev libreadline-dev libffi-dev fuse make gcc ruby"

  for lib in $LIBS; do
    sudo apt-get install $lib -y
  done

  sudo apt-get update
}


install_ruby(){
  wget -O ruby-install-0.7.0.tar.gz https://github.com/postmodern/ruby-install/archive/v0.7.0.tar.gz .tmp
  tar -xzvf ruby-install-0.7.0.tar.gz
  cd ruby-install-0.7.0
  sudo make install


  ruby-install --latest ruby --no-reinstall
}

install_chruby(){
  wget -O chruby-0.3.9.tar.gz https://github.com/postmodern/chruby/archive/v0.3.9.tar.gz
  tar -xzvf chruby-0.3.9.tar.gz
  cd chruby-0.3.9
  sudo make install
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
  echo "ruby-2.6" > ~/.ruby-version
  source ~/.bashrc
}

install_gems(){
  GEMS="bundler colorls neovim rake pry"
  for item in $GEMS; do
    gem install $item
  done
}

run
