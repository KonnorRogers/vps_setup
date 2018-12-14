# Purpose
* To be able to spin up multiple development environments without having to reconfigure all the time
* ### <strong>Note:</strong> This is a fragile process and currently is OS dependent. Currently only tested and working with Ubuntu 18.04 LTS on Linode
* Ideally, you should brush over the contents of each file
* .rc files located in config/

## Warnings
* ### This will update your /etc/ssh/sshd_config file.
* ### Your original can be obtained at /etc/sshd/sshd_config.orig
  
* This will also update your dotfiles
* dotfiles should be able to be restored by appending a .orig to the file like so

      ~/.vimrc.orig
      ~/.tmux.conf.orig
      ~/.zshrc.orig
      
## Updating linode instance
    sudo apt install git
    git clone https://github.com/ParamagicDev/vps-setup.git ~/vps-setup
    sudo bash /path/to/vps-setup/linode.bash -u #{username}
* -u specifies the home directory where everything will be installed, just in case its being run from root

* Do not forget to set git via:
    
      git config --global user.name

* Then run:

      heroku login
      
* Also, ensure to secure your server via /etc/ssh/sshd_config should you not find my settings acceptable

## Setup

* Ensure you go into your server and secure it properly

* For viewing apps over ssh, ensure to use
        
      ssh -L <localport>:localhost:<remoteport> user@ssh.com
      
* At full speed it should look like: 
       
      ssh -L 9000:localhost:3000 user@remoteserver.com
      
* Then you can visit <strong>localhost:9000</strong> in your browser and view your web app
* Alternatively, ngrok is installed via linode.bash 
      
      ngrok http <localport>
      ngrok http 3000 
      
* This will bring up a CLI to connect to for example localhost:3000 on the web  
## Dependencies Installed

* There are many dependencies installed, a large list can be located in 
* /path/to/vps-setup/linode.bash

## Tools installed

* Vim / Neovim
* Zsh / OhMyZsh
* Tmux w/ tmux plugin manager - Terminal multiplexer
* Mosh - Mobile Shell
* Asciinema - records your terminal
* Docker (Installed but not used currently)
* Heroku CLI (--classic)
* Ufw - Allows only certain people to connect
* Httpie - for playing around with API requests

## Languages / Frameworks installed
* Nodejs
* Yarn
* Npm
* sqlite3
* Python3 / pip
* Golang
* Ruby 2.5.1
* Chruby
* Ruby-Install
* Rails

## Gems
* pry - Ruby debugger / IRB alternative
* bundler - package manager
* neovim - neovim support
* colorls - colorful file display
* rake
* rails


## Updates for the future?
    
* Adding docker support via images

* Putting everything into a Rakefile / Task
