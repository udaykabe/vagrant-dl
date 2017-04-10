#!/usr/bin/env sh

#################################################
##  PIP INSTALLATON SCRIPT                      #
#################################################

echo ">>>  INSTALLING PYTHON PIP... as `whoami`"

sudo apt-get update

# use redirection to prevent printing following message to screen (on Ubuntu only?)
# ==> default: dpkg-preconfigure: unable to re-open stdin: No such file or directory
sudo apt-get install -y python-pip >/dev/null 2>&1
sudo -H pip install --upgrade pip
