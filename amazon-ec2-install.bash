#!/bin/bash

USER="ec2-user"
yum update -y

PACKAGE_LIST="curl git vim docker zsh gcc"

for item in $PACKAGE_LIST; do
	echo "installing $item"
	yum install -y $item
done

# install oh-my-zsh
echo 'installing ohmyzsh'
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# set default shell to zsh

echo 'setting default shell to zsh'
chsh -s /usr/bin/zsh $USER

# install rvm - ruby version manager w/ rails

echo 'installing rvm'
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
\curl -sSL https://get.rvm.io | bash


# reload the the shell to use rvm

# echo 'reloading rvm'
# source /home/ec2-user/.rvm/scripts/rvm

# install droid sans mono for powerlevel9k theme
# needs to be fixed to use nerdfonts
#echo 'installing droid sans mono'
# clone
 git clone https://github.com/powerline/fonts.git --depth=1
# install
  cd fonts
  ./install.sh DroidSansMono
 # clean-up a bit
cd ..
rm -rf fonts

# install powerlevel9k

echo 'installing powerlevel9k"

# downloading powerlevel 9k
touch ~/.oh-my-zsh/custom/themes/powerlevel9k
git clone https://github.com/bhilburn/powerlevel9k.git ~/.oh-my-zsh/custom/themes/powerlevel9k

# set zsh to 256 color


# updating zsh
# git clone https://github.com/ParamagicDev/dotfiles.git ~/ec2-user
# rm ~/.zshrc
mv ~/dotfiles/.zshrc ~/.zshrc
source ~/.zshrc

# installing colorls gem

gem install colorls
echo "alias cls='colorls'" >> ~/.zshrc

# syntax highlight and auto suggestion

git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestion
