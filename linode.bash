username="paramagician"
email="konnor5456@gmail.com"


# if 'getent passwd $1 > /dev/null 2>&1'; then
#    echo "$username is already being used!" || true
# else
#   echo "$username is not taken!"
#   adduser $username
#   adduser $username sudo
#fi

sudo apt update
sudo apt upgrade -y
sudo apt autoremove -y
PACKAGE_LIST="curl software-properties-common tmux git vim zsh gnupg2 sqlite3 postgresql less python3 python3-pip python-dev python3-dev python-pip ufw pry ack-grep libfuse2 fuse python3-neovim build-essential bison zlib1g-dev libyaml-dev libssl-dev libgdbm-dev libreadline-dev libffi-dev"



for item in $PACKAGE_LIST; do
  sudo apt install $item -y
done

# setup git
git.config --global user.name paramagicdev 
git.config --global user.email $email

# set tmux
rm -f ~/.tmux.conf
cp ~/vps-setup/tmux.conf ~/.tmux.conf
# add tmux plugin manager
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# install nvim
sudo apt-add-repository ppa:neovim-ppa/stable
sudo apt-get update
sudo apt-get install neovim
# update editor
sudo update-alternatives --install /usr/bin/vi vi /usr/bin/nvim 60
sudo update-alternatives --config vi
sudo update-alternatives --install /usr/bin/vim vim /usr/bin/nvim 60
sudo update-alternatives --config vim
sudo update-alternatives --install /usr/bin/editor editor /usr/bin/nvim 60
sudo update-alternatives --config editor
# update python3 & python2 - neovim
sudo pip2 --user install neovim
sudo pip3 --user install neovim

# install nvim plugin manager
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
# Recursively copies nvim setup
rm -f ~/.config/nvim/init.vim
cp ~/vps-setup/nvim/init.vim ~/.config/nvim/init.vim

# Copy vimrc should neovim have issues
rm -f ~/.vimrc
cp ~/vps-setup/vimrc ~/.vimrc

# install mosh
sudo apt-get install python-software-properties
sudo add-apt-repository ppa:keithw/mosh
sudo apt-get update
sudo apt-get install mosh

## enabling traffic
sudo ufw default allow outgoing
sudo ufw default deny incoming
sudo ufw allow ssh
sudo ufw allow 80/tcp
sudo ufw allow http/tcp

# configure server to accept mosh connections
sudo ufw allow port 60000:61000 proto udp

# enable firewall
sudo ufw enable

# install docker
snap install docker

# Configure docker
groupadd docker
usermod -aG docker $username
systemctl enable docker
systemctl restart docker.service

# install chruby
cd ~
wget -O chruby-0.3.9.tar.gz https://github.com/postmodern/chruby/archive/v0.3.9.tar.gz
tar -xzvf chruby-0.3.9.tar.gz
cd chruby-0.3.9/
sudo make install

#install ruby-install
wget -O ruby-install-0.7.0.tar.gz https://github.com/postmodern/ruby-install/archive/v0.7.0.tar.gz
tar -xzvf ruby-install-0.7.0.tar.gz
cd ruby-install-0.7.0/
sudo make install

# install ruby
ruby-install ruby-2.5.1
echo "ruby-2.5.1" > ~/.ruby-version


# install gems
gem install bundler
gem install rails -v 5.2.0
gem install colorls
gem install neovim


# install nodejs for rails pipeline
cd /tmp
# installs nodejs as root. Important note, will not properly install if not root
\curl -sSL https://deb.nodesource.com/setup_10.x -o nodejs.sh | bash -
less nodejs.sh
cat /tmp/nodejs.sh | sudo -E bash -
sudo apt install -y nodejs
npm install -g neovim
# install ohmyzsh
# sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
git clone https://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh
cp ~/.zshrc ~/.zshrc.orig
rm -f ~/.zshrc
cp ~/vps-setup/zshrc ~/.zshrc
chsh -s /bin/zsh

ZSH_PLUGINS="~/.oh-my-zsh/custom/plugins"
rm -f $ZSH_PLUGINS/zsh-autosuggestions
rm -f $ZSH_PLUGINS/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_PLUGINS/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_PLUGINS/zsh-syntax-highlighting

rm -f ~/.oh-my-zsh/custom/themes/powerlevel9k
git clone https://github.com/bhilburn/powerlevel9k.git ~/.oh-my-zsh/custom/themes/powerlevel9k


cd ~
source ~/.zshrc

