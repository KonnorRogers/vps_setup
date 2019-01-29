#!/bin/bash

sudo apt-get update
sudo apt-get install openssh -y
MINPARAMS=1

echo
if [[ $# -lt "$MINPARAMS" ]]; then
  echo "This script requires an email parameter." 1>&2
  exit 1
fi

ssh-keygen -t rsa -b 4096 -C "$1"

if eval $(ssh-agent -s); then
  ssh-add ~/.ssh/id_rsa
else
  echo "Unable to save a ssh-key"
fi

