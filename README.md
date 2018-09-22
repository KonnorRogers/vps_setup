# Purpose
    To be able to spin up multiple development environments without
    having to reconfigure all the time
     
    Note: this is a fragile process and currently is OS dependent. Currenly only testing and working with
    Ubuntu 18.04 LTS on Linode


# Warnings
   This is a very fragile process only currently tested in a ubuntu 18.04 environment

# Updating amazon ec2 instance as text

    Amazon instances not currently test

    sudo yum install git -y
    git clone https://github.com/ParamagicDev/vps-setup.git
    sudo bash ~/ec2setup/amazon-ec2-install.bash
  
# Updating linode instance

    sudo apt install git
    git clone https://github.com/ParamagicDev/vps-setup.git
    sudo bash /path/to/vps-setup/linode.bash


# updates for the future?
    
    Possibly creating more robust bash scripts
    Docker files?

