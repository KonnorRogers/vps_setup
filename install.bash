#!/bin/bash

if [[ $HOME == '/root' ]]; then
  echo "You are running this as root."
  echo "Add a user to run this script."

  read -p "Username: " uservar

  echo "Adding user $uservar"
  adduser "$uservar"
  adduser "$uservar sudo"
  echo "$uservar created, login as that user to run this script."
  su - "$uservar"

  echo "Rerun this script as non-root" 1>&2
  exit 1
fi

if [[ `id -u` == 0 ]]; then 
  echo "Do not run this as sudo / root. Rerun this script." 1>&2
  exit 1
fi

GEMS="bundler colorls neovim rake pry"

# install gems and run bundle install prior to sudo
if [[ $OSTYPE == 'linux-gnu' ]]; then
  for item in $GEMS; do
    gem install $item
  done
elif [[ $OSTYPE == 'cygwin' ]]; then
  gem install bundler
fi

bundle install

rake make
