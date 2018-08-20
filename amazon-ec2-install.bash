#!/bin/bash

USER="ec2-user"
yum update -y

# Install dependencies
PACKAGE_LIST="curl tmux git vim docker zsh gcc protobuf-devel boost-devel libutempter-devel ncurses-devel zlib-devel perl-CPAN cpp make automake gcc-c++ protoconf-devel openssl-devel libtool bison build-essential libreadline zlib1g libyaml libc6 libgdbm ncurses python3"

for item in $PACKAGE_LIST; do
	echo "installing $item"
	yum install -y $item
done

# install pip
curl -O https://bootstrap.pypa.io/get-pip.py
python3 get-pip.py --user

# Configure docker
groupadd docker
usermod -aG docker $USER
systemctl enable docker
chkconfig docker on
systemctl restart docker.service

# Install mosh
cd ~
cp ~/ec2setup/.gitconfig ~/.gitconfig
git clone https://github.com/keithw/mosh
cd mosh
./autogen.sh
./configure
make
make install

# install oh-my-zsh
echo 'installing ohmyzsh'

cd ~
git clone https://github.com/bhilburn/powerlevel9k.git ~/powerlevel9k
git clone https://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh
cp ~/powerlevel9k ~/.oh-my-zsh/themes/
cp ~/ec2setup/.zshrc ~/.zshrc

# RVM
# install ruby 2.4 sudo amazon-linux-extras install ruby2.4
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
\curl -sSL https://get.rvm.io | bash
source /etc/profile
rvm user gemsets
source ~/.rvm/scripts/rvm
rvm install 2.5
rvm use 2.5

exec zsh

# install color ls
gem install colorls
