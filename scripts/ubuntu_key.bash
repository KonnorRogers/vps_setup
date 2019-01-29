#!/bin/bash

sudo apt-get update
sudo apt-get install gnupg -y

gpg --full-gen-key
