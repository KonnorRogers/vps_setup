#!/bin/bash

apt-cyg update
apt-cyg install gnupg2 -y
gpg2 --full-gen-key
