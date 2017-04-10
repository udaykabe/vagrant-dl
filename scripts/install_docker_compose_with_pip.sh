#!/usr/bin/env sh

#################################################
#  DOCKER-COMPOSE PACKAGE INSTALLATON SCRIPT    #
#################################################

echo ">>>  INSTALLING DOCKER-COMPOSE... as `whoami`"

sudo pip install docker-compose
INSTALL_VERSION=`docker-compose --version | awk '{match($3,/[0-9]+\.[0-9]+\.[0-9]+/,a1); print a1[0]}'`
sudo sh -c "curl -sSL https://raw.githubusercontent.com/docker/compose/bump-$INSTALL_VERSION/contrib/completion/bash/docker-compose > /etc/bash_completion.d/docker-compose"
