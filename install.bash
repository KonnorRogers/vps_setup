#!/bin/bash

if [[ `id -u` == 0 ]]; then 
  echo "Do not run this as sudo / root. Rerun this script." 1>&2
  exit 1
fi

LIBS="software-properties-common npm gnupg2 less ufw ack-grep libfuse2 apt-transport-https ca-certificates build-essential bison zlib1g-dev libyaml-dev libssl-dev libgdbm-dev libreadline-dev libffi-dev fuse make gcc ruby"

for lib in $LIBS; do
  sudo apt-get install $lib -y
done

# for some reason it doesnt work when placed in LIBS
# sudo apt-get install npm -y


mkdir -p .tmp

cd .tmp
wget -O chruby-0.3.9.tar.gz https://github.com/postmodern/chruby/archive/v0.3.9.tar.gz
tar -xzvf chruby-0.3.9.tar.gz
cd chruby-0.3.9
sudo make install

cd ..

wget -O ruby-install-0.7.0.tar.gz https://github.com/postmodern/ruby-install/archive/v0.7.0.tar.gz .tmp
tar -xzvf ruby-install-0.7.0.tar.gz
cd ruby-install-0.7.0
sudo make install

cd ../..

ruby-install --latest ruby --no-reinstall

filename="/etc/profile.d/chruby.sh"
add_chruby="if [ -n "\$BASH_VERSION" ] || [ -n "\$ZSH_VERSION" ]; then
  source /usr/local/share/chruby/chruby.sh
  source /usr/local/share/chruby/auto.sh
 fi" 

if  ! grep -q "$add_chruby" "$filename"; then
  echo "$add_chruby" | sudo tee -a "$filename"
else
  echo "chruby already added"	
fi

echo "ruby-2.6" > ~/.ruby-version
source ~/.bashrc

GEMS="bundler colorls neovim rake pry"

# install gems and run bundle install prior to sudo
if [[ $OSTYPE == 'linux-gnu' ]]; then
  for item in $GEMS; do
    gem install $item
  done
elif [[ $OSTYPE == 'cygwin' ]]; then
  pact install ruby || apt-cyg install ruby
  gem install bundler
fi

bundle install

rake make
