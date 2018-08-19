#!/bin/bash

USER="ec2-user"
yum update -y

PACKAGE_LIST="curl git vim docker-ce zsh gcc"

for item in $PACKAGE_LIST; do
	echo "installing $item"
	yum install -y $item
done


cd ~
wget -O chruby-0.3.9.tar.gz https://github.com/postmodern/chruby/archive/v0.3.9.tar.gz
tar -xzvf chruby-0.3.9.tar.gz
cd chruby-0.3.9/
sudo make install

# install oh-my-zsh
echo 'installing ohmyzsh'
# sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

cd ~
git clone https://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh
cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc
chsh -s /bin/zsh

