#!/usr/bin/env bash

# Installs RDF tools.

set -e

# START OF SETTINGS SECTION

SRC_BASE=src

INSTALL_DIR=/usr/local/bin
ANY23_VERSION=1.1

# END OF SETTINGS SECTION

# Does the source base directory exist? No? Well, create it!
cd ~
if [[ ! -d "$SRC_BASE" ]] ; then
    mkdir "$SRC_BASE"
fi
cd "$SRC_BASE"

sudo apt-get install -y wget

# Install Ruby and RubyGems first:
sudo apt-get install -y ruby

# Install rdf2json:
sudo gem install rdf2json

# Install Apache Any23:
wget http://ftp.jaist.ac.jp/pub/apache/any23/1.1/apache-any23-core-${ANY23_VERSION}.tar.gz
tar xzf apache-any23-core-${ANY23_VERSION}.tar.gz
cd apache-any23-core-${ANY23_VERSION}
chmod 777 bin
if [[ -f "$INSTALL_DIR/any23" ]] ; then
    sudo rm -f "$INSTALL_DIR/any23"
fi
sudo ln -s "`pwd`/bin/any23" "$INSTALL_DIR/any23"

