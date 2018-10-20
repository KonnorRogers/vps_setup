# Purpose
    To be able to spin up multiple development environments without
    having to reconfigure all the time
     
    Note: this is a fragile process and currently is OS dependent. Currenly only testing and working with
    Ubuntu 18.04 LTS on Linode


# Warnings
   This is a very fragile process only currently tested in a ubuntu 18.04 environment
   Currently, there is no Xforwarding setup because I am working from a cygwin environment

## NOT SUPPORTED CURRENTLY

    Amazon instances not currently test

    sudo yum install git -y
    git clone https://github.com/ParamagicDev/vps-setup.git
    sudo bash ~/ec2setup/amazon-ec2-install.bash
     
  
# Updating linode instance

    sudo apt install git
    git clone https://github.com/ParamagicDev/vps-setup.git
    sudo bash /path/to/vps-setup/linode.bash

# Setup

<p> Not everything could be done via bash script </p>
<p> Ensure you go into your server and secure it properly </p>
<p> For viewing apps over ssh, ensure to use </p>
    ssh -L <localport>:localhost:<remoteport> user@ssh.com

<p> At full speed it should look like: </p>
    ssh -L 9000:localhost:4567 user@remoteserver.com

<p> Also, to setup heroku, ensure to use: </p>

    heroku login


# updates for the future?
    
    Adding docker instead of manual installs
