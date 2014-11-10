#!/usr/bin/env bash

# Installs basic components for a C development environment.

set -e

sudo apt-get -y install codeblocks
sudo apt-get -y install emacs23-nox
sudo apt-get -y install automake
sudo apt-get -y install clang
sudo apt-get -y install cmake

