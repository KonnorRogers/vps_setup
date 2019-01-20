#!/bin/bash

sudo apt-get install gnupg
sudo apt-get install rng-tools

gen_key(){
  # outputs random entropy for key gen
  sudo rngd -r /dev/urandom

  # makes the key
  gpg --gen-key

  # kill the rng process
  pid=$(pgrep -i rngd)
  sudo kill -9 "$pid"
}

gpg --list-keys
exit_code=$?

if [[ $exit_code -eq 0 ]]; then
  echo "You already have a GPG key. You do not need to create one"
else
  gen_key
fi


PID=$(pgrep -i rngd)
echo $PID
