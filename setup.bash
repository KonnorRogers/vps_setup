#!/bin/bash
main(){
  # will error if running as root
  check_if_root

  # runs through the varios sudo apt installs required prior to
  # installs
  apt_setup
  
  # Only install sops if no executable found
  if ! [[ -x "$(command -v sops)" ]]; then
    source "scripts/install_sops.bash"
  fi

  cd "scripts/version-managers" || echo "unable to cd to scripts/version-managers" 1>&2 && exit 1

  for i in *.bash; do
    source "$i"
  done

  cd "../../" || echo "Unable to return to base directory" 1>&2 && exit 1

  source "scripts/restart_shell.bash"
  gem install bundler
  bundle install
  bundle update
}

check_if_root(){
  if [[ $(id -u) == 0 ]]; then 
    echo "Do not run this as sudo / root. Rerun this script." 1>&2
    exit 1
  fi
}

# this will do a few things:
# it will run update, upgrade & dist-upgrade. dist-upgrade will upgrade the 
# ubuntu distro.
# additionally, it will fetch the inital packages needed prior to running 
# the rakefile
apt_setup(){
  sudo apt-get update
  sudo apt-get upgrade -y

  libs='software-properties-common gnupg2 less ufw ack-grep libfuse2
  apt-transport-https ca-certificates build-essential bison zlib1g-dev 
  libyaml-dev libcurl4-openssl-dev libssl-dev libgdbm-dev libreadline-dev libffi-dev fuse
  make gcc ruby ruby-dev golang php'
  sudo apt-get install $libs -y

  sudo apt-get update
  sudo apt-get autoremove -y
}

# runs the main method
main
