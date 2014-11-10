#!/usr/bin/env bash

# Installs, configures, and starts the open source version of Virtuoso.

set -e

# START OF SETTINGS SECTION
#

# Virtuoso and data directories will go here:
#
# NOTE: directory is relative to home (~/), so "src" will be
#       referring to the directory "~/src"
SRC_BASE=src

VIRTUOSO_VERSION=develop/7

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

# Get Virtuoso and build it:
git clone https://github.com/openlink/virtuoso-opensource.git
cd virtuoso-opensource
git checkout $VIRTUOSO_VERSION
./autogen.sh
export CFLAGS="-O2 -m64"
./configure
make
sudo make install

# Start Virtuoso:
echo ""
echo "!!! Showing Virtuoso admin interface in Firefox in 30sec !!!"
echo ""
(sleep 30; firefox http://127.0.0.1:8890) &
cd /usr/local/virtuoso-opensource/var/lib/virtuoso
sudo chown -R `whoami` db
cd db
/usr/local/virtuoso-opensource/bin/virtuoso-t +foreground

