#!/usr/bin/env bash

# Installs basic components for a C development environment.

set -e

sudo apt-get -y install vim
sudo apt-get -y install git
sudo apt-get -y install tmux
sudo apt-get -y install automake
sudo apt-get -y install clang
sudo apt-get -y install cmake

