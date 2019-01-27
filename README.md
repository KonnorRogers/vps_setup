# Purpose
* To be able to spin up multiple development environments without having to reconfigure all the time
* ### <strong>Note:</strong> This is a fragile process and currently is OS dependent.
* ### Supported OS'es:
  - Ubuntu 18.10 - DigitalOcean
  - Babun on windows, simply pulls dotfiles, pact installs ruby, and bundle installs
  - Ubuntu 18.04 LTS on personal laptop
  
* Ideally, you should brush over the contents of each file
* .rc files located in config/ as well sshd_config & gnome_terminal_settings

## Warnings
* ### This will update your /etc/ssh/sshd_config file.
* ### Your original can be obtained at ~/backup_config/sshd_config.orig

* This will also update your dotfiles
* dotfiles should be able to be restored by appending a .orig to the file like so

```bash
~/backup_config/vimrc.orig
~/backup_config/tmux.conf.orig
~/backup_config/zshrc.orig
```

## Prerequisites
* None as far as I can tell, it should pull in everything you need.
* Ensure to add a user

```bash
adduser username
adduser username sudo
```

* Ensure that you have ssh keys added. I have disabled clear text passwords.
* Easiest way when logged into a new DigitalOcean droplet via ssh and logged in as username:

```bash
username@localhost:~ $ sudo cp -R /root/.ssh ~/.ssh
username@localhost:~ $ sudo chown -R username:username ~/.ssh
```    

* Or by simply adding your SSH public key to ~/.ssh/authorized_keys

```bash
mdkir ~/.ssh
touch ~/.ssh/authorized_keys
echo "MYSSHKEY" >> ~/.ssh/authorized_keys
sudo chmod -R go= ~/.ssh
sudo chown -R $USER:$USER ~/.ssh
```

* ssh directory permissions can be set via:

```bash
./scripts/ssh_perms
```
      
## Updating ubuntu instances

* ### If you run this command as root / sudo, it will prompt you to make a user to use the script as
* ### This will continuously error out if you try to run as root / sudo

```bash
git clone https://github.com/ParamagicDev/vps_setup.git ~/vps_setup
cd ~/vps_setup
bash install.bash
```

* or

```bash
./install.bash
```
      
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
* Ruby 2.6.0
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
   
```bash
ssh -L <localport>:localhost:<remoteport> user@ssh.com
```

* At full speed it should look like: 
       
```bash
ssh -L 9000:localhost:3000 user@remoteserver.com
```

* Then you can visit <strong>localhost:9000</strong> in your browser and view your web app
* Alternatively, ngrok is installed via linode.bash 

```bash      
ngrok http <localport>
ngrok http 3000 
```

* This will bring up a CLI to connect to for example localhost:3000 on the web  

## Rake Tasks

### $ rake test
* Default rake task, runs the test suite

### $ rake make[:backup_dir, dest_dir]

* The main function called by install.bash
* will call rake config:copy
* accepts the same arguments as config:copy
* defaults backup_dir to ~/backup_config
* defaults dest_dir to ~

### $ rake config:copy[:backup_dir, dest_dir]

* copies files from vps_setup/config to ~/backup_config:

```bash
rake config:copy
```

* This can be specified with either both or one of the arguments:

```bash
rake "config:copy[/path/to/backup_dir, /path/to/dest_dir]"
```

* The following command lets you specify where you would like your backup directory to be

```bash
rake "config:copy[/path/to/backup_dir]"
```

* The following command lets you specify where you would like to put your dotfiles

```bash
rake "config:copy[nil, /path/to/dest_dir]"
```

### $ rake config:pull[:config_dir, :local_dir]

* #### This is merely to pull local files into your vps_setup repo

* copies files from home dir (~) to your vps_setup repo (./vps_setup/config)

```bash
rake config:pull
```

* Alternatively, you can specify where you would like files to be pulled from and to

```bash
rake "config:pull[/path/to/config_dir, /path/to/local_dotfiles_dir]"
```

* The following command will allow you to show what will be pulled to the repo:

```bash
rake "config:pull[/path/to/config_dir]"
```

* The following command will let you leave the default config dir, and specify where to pull dotfiles from


```bash
rake "config:pull[nil, /path/to/dotfiles_dir]"
```

## Updates for the future?
    
* Adding docker support via images

## Utilities used

* GNUPG2
* RAKE
* THOR
* RUBY
* RDOC
* SOPS


## Things learned:

* Configuration is hard. There is a reason things like chef, puppet, ansible etc exist.
* How to create a logger. Example is in test/logs after running rake test
* Rake is a great tool, but is weak with command line arguments, may look into Thor for the future
* It works, its not pretty, but it gets the job done.
* Mixing command line and Ruby is not easy
* Thor does args well
* Testing apt-get install / apt install etc is nearly impossible unless i were to go through and do a $(command -v) for everything which is not feasible
* My original, non extensible, less easily tested version is available here: 
  [Deprecated Bash Scripting Branch](https://github.com/ParamagicDev/vps_setup/tree/deprecated_bash_scripting)
* NEVER USE A PASSWORD AS A COMMAND LINE ARGUMENT
