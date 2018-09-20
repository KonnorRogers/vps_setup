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
PACKAGE_LIST="curl software-properties-common tmux git vim zsh gnupg2 sqlite3 postgresql less python3 python3-pip python-dev python3-dev python-pip ufw pry ack-grep libfuse2 fuse python3-neovim build-essential bison zlib1g-dev libyaml-dev libssl-dev libgdbm-dev libreadline-dev libffi-dev nodejs apt-transport-https ca-certificates"



for item in $PACKAGE_LIST; do
  sudo apt install $item -y
done

# setup git
git.config --global user.name paramagicdev 
git.config --global user.email $email

# add tmux plugin manager
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# install nvim
sudo apt-add-repository ppa:neovim-ppa/stable
sudo apt-get update
sudo apt-get install neovim -y
# update editor
sudo update-alternatives --install /usr/bin/vi vi /usr/bin/nvim 60
sudo update-alternatives --config vi
sudo update-alternatives --install /usr/bin/vim vim /usr/bin/nvim 60
sudo update-alternatives --config vim
sudo update-alternatives --install /usr/bin/editor editor /usr/bin/nvim 60
sudo update-alternatives --config editor
# update python3 & python2 - neovim
sudo pip2 install neovim -y --user 
sudo pip3 install neovim -y --user 

# install mosh
sudo apt-get install python-software-properties -y
sudo add-apt-repository ppa:keithw/mosh
sudo apt-get update
sudo apt-get install mosh -y

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

# install asciicinema for terminal recording
sudo apt-add-repository ppa:zanchey/asciinema
sudo apt-get update
sudo apt-get install asciinema -y

# install docker
snap install docker -y

# Configure docker
groupadd docker
usermod -aG docker $username

# install chruby
cd ~
if [[ command -v chruby ]]; then
    echo 'chruby is already installed'
else
    wget -O chruby-0.3.9.tar.gz https://github.com/postmodern/chruby/archive/v0.3.9.tar.gz
    tar -xzvf chruby-0.3.9.tar.gz
    cd chruby-0.3.9/
    sudo make install
fi

#install ruby-install
if [[ command -v ruby-install ]]; then 
    echo 'ruby-install is already installed'
else
    wget -O ruby-install-0.7.0.tar.gz https://github.com/postmodern/ruby-install/archive/v0.7.0.tar.gz
    tar -xzvf ruby-install-0.7.0.tar.gz
    cd ruby-install-0.7.0/
    sudo make install
fi
# install ruby
ruby-install ruby-2.5.1
echo "ruby-2.5.1" > ~/.ruby-version


# install gems
gem install bundler
gem install rails -v 5.2.0
gem install colorls
gem install neovim

# Install neovim-npm
npm install -g neovim -y

# Install zsh and accompanying plugins
if [[ ! -e "~/.oh-my-zsh" ]]; then
    git clone https://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh
    chsh -s /bin/zsh
fi

ZSH_PLUGINS="~/.oh-my-zsh/custom/plugins"

if [[ ! -e "$ZSH_PLUGINS/zsh-autosuggestions" ]]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_PLUGINS/zsh-autosuggestions
else
    echo 'zsh-autosuggestions already exists'
fi

if [[ ! -e "$ZSH_PLUGINS/zsh-syntax-highlighting" ]]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_PLUGINS/zsh-syntax-highlighting
else
    echo 'zsh-syntax-highlighting already exists'
fi

ZSH_THEMES="~/.oh-my-zsh/custom/themes"
if [[ ! -e "$ZSH_PLUGINS/powerlevel9k" ]]; then
    git clone https://github.com/bhilburn/powerlevel9k.git ~/.oh-my-zsh/custom/themes/powerlevel9k
else
    echo 'Powerlevel9k already exists'
fi

DOTFILES="~/vps-setup/change.bash"
if [[ -e "$DOTFILES" ]]; then
    sudo bash "$DOTFILES"
else
    echo "$DOTFILES does not exist. Run change.bash to transfer over dotfiles." 
fi

cd ~
source ~/.zshrc

