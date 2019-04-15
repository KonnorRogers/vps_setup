# Purpose
* To be able to spin up multiple development environments without having to reconfigure all the time
* ### <strong>Note:</strong> This is a fragile process and currently is OS dependent.
* ### Supported OS'es:
  - Ubuntu 18.10 - DigitalOcean
  - Ubuntu 18.04 on personal laptop
  - Lubuntu 18.10 on a seperate personal laptop 
  
* Ideally, you should brush over the contents of each file
* .rc files located in config_files/dotfiles
* config_files/misc_files contains non dotfiles such as sshd_config & gnome_terminal_settings

## Warnings
* ### This will update your /etc/ssh/sshd_config file.
* ### Your original can be obtained at ~/backup_files/sshd_config.orig

* This will add source chruby to your .bashrc or .zshrc file
* This is done during setup.sh

* This will also update your dotfiles
* dotfiles should be able to be restored by appending a .orig to the file like so
* if a dotfile backup already exists, no backup will be created

```bash
~/backup_files/vimrc.orig
~/backup_files/tmux.conf.orig
~/backup_files/zshrc.orig
```

## Prerequisites
* None as far as I can tell, it should pull in everything you need.

## How i use this script

1. Ensure your ssh key is inside of your DigitalOcean droplet under
   security
   
   ** If you have an existing droplet, consult digitalocean documents on adding
   an ssh key

2. Create your droplet

3. ssh into your server

```bash
ssh root@<ip_address>
```

4. Create a new user, do not use root as your main user. Ensure to give your
   user sudo permissions

```bash
adduser <username>
adduser <username> sudo
```

* Ensure that you have ssh keys added. I have disabled clear text passwords.

5. Clone the repo & setup for use

```bash
git clone https://github.com/ParamagicDev/vps_cli.git ~/vps_cli
cd ~/vps_cli
./setup.bash
```

6. Setup pgp keys
** If you have not setup PGP / GPG before, you can follow my guide:
[My Guide to setting up PGP / GPG](https://github.com/ParamagicDev/vps_cli/issues/12)

** export you PGP key for use by sops

```bash
export SOPS_PGP_FP="$KEY_ID"
```

** Your $KEY_ID can be obtained by running:

```bash
gpg --list-keys
```

7. Next step is to create a .credentials.yaml file in your home directory

```bash
sops ~/.credentials.yaml
```

** Follow the same layout as provided inside of this repo @ [example_credentials.yaml](https://github.com/ParamagicDev/vps_cli/blob/master/example_credentials.yaml)
** ensure your github api token has read:public_key & write_public_key scope as
well as in the format "token 123456789"

** You can either use scp to send the file from your local computer to your
server, or you can simply create a new one everytime.

8. Run a fresh install, this will provide you with all my dotfiles,
all the ways I like everything setup etc.

```bash
vps-cli fresh_install
```

* or

```bash
./exe/vps-cli fresh_install
```

9. To pull in any local changes into your repo run: 

```bash
vps-cli pull -a
```

10. To copy any changes from your repo to your local files, run: 

```bash
vps-cli copy -a
```

** <strong>This will only pull / copy dotfiles already found within
config_files/misc_files & config_files/dotfiles</strong>
** To add additional dotfiles, add them to config_files/dotfiles

## Dependencies Installed

* There are many dependencies installed, a large list can be located in:
* /path/to/vps_cli/setup.bash
* /path/to/vps_cli/lib/vps_cli/packages.rb

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
* gnome-terminal - gnome terminal emulator

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

## Viewing localhost of the server
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
gpg --import /path/to/vps_cli/sops_testing_key.asc
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
* This projected ended up being way bigger than expected, I need to get back to
web development

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
