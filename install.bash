#!/bin/bash

# if [[ $HOME == '/root' ]]; then
#   echo "Please add a user to run this script as"
#   read -p 'Username: ' uservar
#   adduser $uservar
#   adduser $uservar sudo
#   echo "Please rerun this script as the new user" 1>&2
#   exit 1
# fi

if [[ $OSTYPE == 'linux-gnu' ]]; then
  sudo apt-get install ruby
elif [[ $OSTYPE == 'cygwin' ]]; then
  sudo pact install ruby
fi

gem install bundler
bundle install

sudo rake make
