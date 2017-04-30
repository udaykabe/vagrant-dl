#!/usr/bin/env sh

#########################################
#  DOCKER INSTALLATON SCRIPT            #
#########################################

# visit http://tecadmin.net/install-and-manage-docker-on-ubuntu/
# and
# https://docs.docker.com/engine/installation/linux/ubuntulinux/
echo ">>>  INSTALLING DOCKER... as `whoami`"

DISTRO=$(lsb_release -is | tr '[:upper:]' '[:lower:]') # => ubuntu
CODENAME=$(lsb_release -cs) # => e.g., xenial

# Install recommended prerequisite kernel package 'linux-image-extra' which allows use of the aufs storage driver.
apt-get install -y linux-image-extra-$(uname -r)

# Import docker GPG key in order to verify package signatures before installation
apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D

# Add docker APT repo which hosts docker package
# This fails with permission denied
# sudo echo "..." >> /etc/apt/sources.list.d/docker.list

# So do the following instead
echo "deb https://apt.dockerproject.org/repo $DISTRO-$CODENAME main" > /etc/apt/sources.list.d/docker.list

# Update package index
apt-get update

# Purge old repo if it exists
apt-get purge lxc-docker

# Verify that the Docker repo, and not the Ubuntu repo, is used
apt-cache policy docker-engine

# finally install the docker engine
# use redirection to prevent printing following message to screen (on Ubuntu only?)
# ==> default: dpkg-preconfigure: unable to re-open stdin: No such file or directory
apt-get install -y docker-engine >/dev/null 2>&1

#
# Why use all of the above instead of the following single command?
# Because it does not install the latest version of docker!
#
#sudo apt-get -y install docker.io

# Start docker
# [[ $CODENAME = "trusty" ]] && service docker start

# Set up docker to start on boot
#sudo update-rc.d docker defaults
# docs.docker.io suggests the following for 15.04 and up
if [ $CODENAME = "xenial" ]; then systemctl enable docker; fi
#if [ $CODENAME = "xenial" ]; then systemctl status docker; fi
