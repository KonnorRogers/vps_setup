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


wget -O chruby-0.3.9.tar.gz https://github.com/postmodern/chruby/archive/v0.3.9.tar.gz
tar -xzvf chruby-0.3.9.tar.gz
cd chruby-0.3.9/
sudo make install


mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts && curl -fLo "Literation Mono for Powerline Nerd Font Complete.ttf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/LiberationMono/complete/Literation%20Mono%20Nerd%20Font%20Complete%20Mono%20Windows%20Compatible.ttf

# install powerlevel9k

echo 'installing powerlevel9k"

# downloading powerlevel 9k
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
