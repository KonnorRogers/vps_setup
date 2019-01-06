# Purpose
* To be able to spin up multiple development environments without having to reconfigure all the time
* ### <strong>Note:</strong> This is a fragile process and currently is OS dependent. Currently only tested and working with Ubuntu 18.04 LTS on Linode & Babun on windows.
* Ideally, you should brush over the contents of each file
* .rc files located in config/ as well sshd_config & gnome_terminal_settings

## Warnings
* ### This will update your /etc/ssh/sshd_config file.
* ### Your original can be obtained at ~/backup_config/sshd_config.orig

* This will also update your dotfiles
* dotfiles should be able to be restored by appending a .orig to the file like so

      ~/backup_config/vimrc.orig
      ~/backup_config/tmux.conf.orig
      ~/backup_config/zshrc.orig

## Prerequisites

* Ensure ruby is installed, preferably 2.3.3 or greater
      
## Updating linode instance

* ### If you run this command as root, it will prompt you to make a user to use the script as

* ### DO NOT RUN THE SCRIPT AS SUDO
* ### It will prompt for sudo when needed

      sudo apt install git
      git clone https://github.com/ParamagicDev/vps-setup.git ~/vps-setup
      cd ~/vps-setup
      bash install.bash
    
* or
  
      ./install.bash
      
* This will run heroku login & git config --global user.name & user.email

* Also, ensure to secure your server via /etc/ssh/sshd_config should you not find my settings acceptable

## Dependencies Installed

* There are many dependencies installed, a large list can be located in 
* /path/to/vps-setup/lib/vps_setup/packages.rb

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

## Rake Tasks

### $ rake make

* The main function called by install.bash
* will call rake config:copy
* accepts the same arguments as config:copy
* defaults backup_dir to ~/backup_config
* defaults dest_dir to ~

### $ rake config:copy[:backup_dir, dest_dir]

* copies files from vps_setup/config to ~/backup_config:

      rake config:copy

* This can be specified with either both or one of the arguments:

      rake "config:copy[/path/to/backup_dir, /path/to/dest_dir]"
      
* The following command lets you specify where you would like your backup directory to be

      rake "config:copy[/path/to/backup_dir]"
      
* The following command lets you specify where you would like to put your dotfiles

      rake "config:copy[nil, /path/to/dest_dir]"

### $ rake config:pull[:config_dir, :local_dir]

* #### This is merely to pull local files into your vps_setup repo

* copies files from home dir (~) to your vps_setup repo (./vps_setup/config)

      rake config:pull

* Alternatively, you can specify where you would like files to be pulled from and to

      rake "config:pull[/path/to/config_dir, /path/to/local_dotfiles_dir]"
      
* The following command will allow you to show what will be pulled to the repo:

      rake "config:pull[/path/to/config_dir]"

* The following command will let you leave the default config dir, and specify where to pull dotfiles from

      rake "config:pull[nil, /path/to/dotfiles_dir]"


## Updates for the future?
    
* Adding docker support via images
