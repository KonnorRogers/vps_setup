#!/bin/bash

SSH_CONFIG="/etc/ssh/sshd_config"
# Disable root login
disable_root_login(){
    echo "# Authentication" >> "$SSH_CONFIG"
    echo "PermitRootLogin no" >> "$SSH_CONFIG"
}

disable_clear_text_password(){
    echo "# When set to no, disables tunnelled clear text passwords" >> "$SSH_CONFIG"
    echo "PasswordAuthentication no" >> "$SSH_CONFIG"
}

disable_ipv6(){
    echo "Enables on ipv4 connectivity. Change to AddressFamily inet6 for ipv6" >> "$SSH_CONFIG"
    echo "AddressFamily inet" >> "$SSH_CONFIG"
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
    SSH=eval "$(ps -ef | grep sshd)"
    if [[ $SSH == '' ]]; then
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

