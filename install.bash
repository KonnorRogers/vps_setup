#!/bin/bash

if [[ $OSTYPE == 'linux-gnu' ]]; then
  sudo apt-get install ruby
elif [[ $OSTYPE == 'cygwin' ]]; then
  sudo pact install ruby
fi

gem install bundler
bundle install

sudo rake make
