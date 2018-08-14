#!/bin/bash

USER="ec2-user"
sudo yum update

$PACKAGE_LIST="curl git vim docker zsh"

for item in $PACKAGE_LIST
	echo "installing #$item"
	sudo yum install -y $item
end

# install oh-my-zsh
echo 'installing ohmyzsh'
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# set default shell to zsh

echo 'setting default shell to zsh'
sudo chsh -s /usr/bin/zsh $USER

# install rvm - ruby version manager w/ rails

echo 'installing rvm'
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
\curl -sSL https://get.rvm.io | bash -s stable --rails

# reload the the shell to use rvm

echo 'reloading rvm'
source /home/ec2-user/.rvm/scripts/rvm

# install furacode for powerlevel9k theme

echo 'installing firacode'
# clone
git clone https://github.com/powerline/fonts.git --depth=1
# install
cd fonts
./install.sh FiraMono
# clean-up a bit
cd ..
rm -rf fonts

# install powerlevel9k

echo 'installing powerlevel9k"

# downloading powerlevel 9k
git clone https://github.com/bhilburn/powerlevel9k.git ~/.oh-my-zsh/custom/themes/powerlevel9k


# updating zsh

echo "POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(ssh dir vcs newline status)" >> ~/.zshrc
echo "POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=()" >> ~/.zshrc
echo "POWERLEVEL9K_PROMPT_ADD_NEWLINE=true" >> ~/.zshrc

# adding an alias for ls -G

echo "alias ls='ls -G'" >> ~/.zshrc

# installing colorls gem

gem install colorls
echo "alias cls='colorls'" >> ~/.zshrc

# syntax highlight and auto suggestion

git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestion
