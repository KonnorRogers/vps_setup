# Purpose
* To be able to spin up multiple development environments without having to reconfigure all the time
* ### <strong>Note:</strong> This is a fragile process and currently is OS dependent.
* ### Supported OS'es:
  - Ubuntu 18.10 - DigitalOcean
  - Ubuntu 18.04 LTS on personal laptop
  
* Ideally, you should brush over the contents of each file
* .rc files located in config/ as well sshd_config & gnome_terminal_settings

## Warnings
* ### This will update your /etc/ssh/sshd_config file.
* ### Your original can be obtained at ~/backup_files/sshd_config.orig

* This will add "chruby ruby latest" to your .bashrc or .zshrc file
* This will also source chruby in .bashrc or .zshrc file
* This is done during setup.sh

* This will also update your dotfiles
* dotfiles should be able to be restored by appending a .orig to the file like so

```bash
~/backup_files/vimrc.orig
~/backup_files/tmux.conf.orig
~/backup_files/zshrc.orig
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
git clone https://github.com/ParamagicDev/vps_cli.git ~/vps_cli
cd ~/vps_cli
bash setup.bash
```

* or

```bash
./setup.bash
```
      
## Dependencies Installed

* There are many dependencies installed, a large list can be located in 
* /path/to/vps-setup/setup.bash

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
* PGP / GPG - Public / Private key authentication

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

## Testing

* Import the gpg dev key, I just took the one from [The mozilla SOPS github](https://github.com/mozilla/sops#test-with-the-dev-pgp-key) and
added it into this repo for testing purposes.

```bash
gpg --import sops_testing_key.asc
```

* The test suite will fail if the testing key is not present, this is to be expected
```bash
rake test
```

## vps-cli commands

* if you have not run the setup script you can do the following:

```bash
cd exe
./vps-cli [COMMAND] [OPTIONS]
```

### Example commands

* The following command will copy all files to $HOME directory from
</path/to/vps_cli/config_files>. With the --interactive flag, it will
prompt the user before overwriting any files.

```bash
vps-cli copy --all --interactive
```

* The following command will pull files from the local directory ($HOME)
to </path/to/vps_cli/config_files>

```bash
vps-cli pull --all
```

* This is still a work in progress. More commands and flags will be added

## Contents of credentials.yaml

* An example can be found of how to format your credentials.yaml file here:
* [Example credentials.yaml file](https://github.com/ParamagicDev/vps_cli/blob/thor/example_credentials.yaml)

## Updates for the future?
    
* Adding docker support via images

## Utilities used

* [RAKE](https://github.com/ruby/rake) For various command line tasks
* [THOR](https://github.com/erikhuda/thor) For command line options via ruby
* [YARD](https://yardoc.org/) For documentation of code
* [GNUPG2](https://www.gnupg.org/) For GPG keys to be used with sops
* [SOPS](https://github.com/mozilla/sops) For secret management via YAML files


## Things learned:

* Configuration is hard. There is a reason things like chef, puppet, ansible etc exist.
* How to create a logger. Example is in test/logs after running rake test
* Rake is a great tool, but is weak with command line arguments, may look into Thor for the future
* It works, its not pretty, but it gets the job done.
* Mixing command line and Ruby is not easy
* Thor does args well
* Testing apt-get install / apt install etc is nearly impossible unless i were to go through and do a File.exist? for everything which is not feasible
* My original, non extensible, less easily tested version is available here: 
  [Deprecated Bash Scripting Branch](https://github.com/ParamagicDev/vps_cli/tree/deprecated_bash_scripting)
* NEVER USE A PASSWORD AS A COMMAND LINE ARGUMENT
* How to remove a file with sensitive information from your commit history via git rebase
* As this project grows, RDoc / YARD is a great way to have an easy view of what everything does
* Created calls to the web via Curl / Net:HTTP provided by Ruby
* Proper storage of secrets such as API keys, SSH keys, etc
* Wrapping something such as sops with Ruby is not easy.
* So much testing on things that are not easy to test
* Scope creep is a real thing and ive experienced it with this project

## ISSUES

* You may encounter the following issue if you have oh-my-zsh already on your machine and running the setup.bash script

```bash
/home/paramagician/.oh-my-zsh/oh-my-zsh.sh: line 23: autoload: command not found
/home/paramagician/.oh-my-zsh/oh-my-zsh.sh: line 34: syntax error near unexpected token `('
/home/paramagician/.oh-my-zsh/oh-my-zsh.sh: line 34: `for config_file ($ZSH/lib/*.zsh); do'
/home/paramagician/.oh-my-zsh/oh-my-zsh.sh: line 23: autoload: command not found
/home/paramagician/.oh-my-zsh/oh-my-zsh.sh: line 34: syntax error near unexpected token `('
/home/paramagician/.oh-my-zsh/oh-my-zsh.sh: line 34: `for config_file ($ZSH/lib/*.zsh); do'
```

* This is because the script is run via bash instead of ZSH, this should not affect anything
