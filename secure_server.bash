#!/bin/bash

SSH_CONFIG="/etc/ssh/sshd_config"
# Disable root login
disable_root_login(){ 
    if [[ -n cat "$SSH_CONFIG" | grep -e "/^\s*PermitRootLogin no \s*$/" ]]; then
        # checks if rootlogin not empty
        echo "Rootlogin is already set to no. No modifications made"
    else
        echo "# Authentication" | sudo tee -a "$SSH_CONFIG"
        echo "PermitRootLogin no" | sudo tee -a "$SSH_CONFIG"
    fi
}

disable_clear_text_password(){
    
    if [[ -n cat "$SSH_CONFIG" | grep -e "/^\s*PasswordAuthentication no\s*$/") ]]; then
        # checks if password authentication is non empty
        echo "PasswordAuthentication already disabled. No modifications made."
    else
        echo "# When set to no, disables tunnelled clear text passwords" | sudo tee -a "$SSH_CONFIG"
        echo "PasswordAuthentication no" | sudo tee -a "$SSH_CONFIG"
    fi
}

disable_ipv6(){

    if [[ -n  cat "$SSH_CONFIG" | grep -e "/^\s*AddressFamily inet\s*$/") ]]; then
        # checks if ipv4 already enabled
        echo "AddressFamily inet already enabled. No Modifications made"
    else
        echo "# Enables on ipv4 connectivity. Change to AddressFamily inet6 for ipv6" | sudo tee -a "$SSH_CONFIG"
        echo "AddressFamily inet" | sudo tee -a "$SSH_CONFIG"
    fi
}

reset_sshd(){
    sudo systemctl restart sshd
}

check_if_sshd_exists(){
    if [[ ! -e "$SSH_CONFIG" ]]; then
        echo "$SSH_CONFIG not found. Please ensure ssh is installed. Exiting."
        exit 1
    fi
}

check_if_ssh_active(){
    SSH="eval $(ps -ef | grep sshd)"
    if [[ $SSH == "" ]]; then
        echo "This is not an SSH server. SSH will not be secured"
        exit 2
    fi
}

# Taken from linode on how to secure a server. Additional to follow
check_if_ssh_active
check_if_sshd_exists
disable_root_login
disable_clear_text_password
disable_ipv6
reset_sshd

