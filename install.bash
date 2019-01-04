#!/bin/bash

$GEMS="bundler rails colorls neovim rake pry"

# install gems and run bundle install prior to sudo
for item in $GEMS; do
  gem install $item
done

bundle install

sudo rake make
