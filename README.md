# Purpose
    To be able to spin up multiple development environments without
    having to reconfigure all the time
     
    Note: this is a fragile process and currently is OS dependent. Currenly only testing and working with
    Ubuntu 18.04 LTS on Linode
    SSH key testing


# Warnings
    if intending to use rvm, DO NOT run this script as a root user. 
    It will cause RVM to not install locally and instead install to root causing other issues as described
    in the RVM installation process
    
# Updating amazon ec2 instance as text

    sudo yum install git -y
    git clone https://github.com/ParamagicDev/vps-setup.git
    sudo bash ~/ec2setup/amazon-ec2-install.bash
  
# Updating linode instance

    sudo apt install git
    git clone https://github.com/ParamagicDev/vps-setup.git
    sudo bash ~/vps-setup/linode.bash


# updates for the future?
    update .tmuxrc
    update neovim/init.vim with ruby / rails related plugins
    add other various devops related things
    use docker more?
