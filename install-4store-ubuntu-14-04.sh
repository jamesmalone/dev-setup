#!/usr/bin/env bash

# Installs, configures, and starts 4store.

set -e

# START OF SETTINGS SECTION
#

# Virtuoso and data directories will go here:
#
# NOTE: directory is relative to home (~/), so "src" will be
#       referring to the directory "~/src"
SRC_BASE=src

# END OF SETTINGS SECTION

# Does the source base directory exist? No? Well, create it!
cd ~
if [[ ! -d "$SRC_BASE" ]] ; then
    mkdir "$SRC_BASE"
fi
cd "$SRC_BASE"

sudo apt-get install -y git
sudo apt-get install -y build-essential
sudo apt-get install -y automake
sudo apt-get install -y gperf
sudo apt-get install -y libtool
sudo apt-get install -y flex
sudo apt-get install -y bison
sudo apt-get install -y libssl-dev
sudo apt-get install -y libraptor2-0
sudo apt-get install -y librasqal3
sudo apt-get install -y libraptor2-dev
sudo apt-get install -y librasqal3-dev
sudo apt-get install -y ncurses-base
sudo apt-get install -y lib64ncurses5
sudo apt-get install -y lib64ncurses5-dev
sudo apt-get install -y libreadline6-dev
sudo apt-get install -y uuid-dev
sudo apt-get install -y libglib2.0-dev

# Get 4store and build it:
git clone https://github.com/garlik/4store.git
cd 4store
./autogen.sh
./configure
make
sudo make install

# Setting up 4store and starting it:
4s-backend-setup default
4s-backend default
echo ""
echo "!!! 4store running in background; KB is 'default' !!!"
echo ""

