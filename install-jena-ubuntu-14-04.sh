#!/usr/bin/env bash

# Installs, configures, and starts Apache Jena (with TDB store).

set -e

# START OF SETTINGS SECTION
#

# Jena and data directories will go here:
#
# NOTE: directory is relative to home (~/), so "src" will be
#       referring to the directory "~/src"
SRC_BASE=src

export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64

JENA_VERSION=2.12.1

# END OF SETTINGS SECTION

# Does the source base directory exist? No? Well, create it!
cd ~
if [[ ! -d "$SRC_BASE" ]] ; then
    mkdir "$SRC_BASE"
fi
cd "$SRC_BASE"

sudo apt-get install -y wget

# Download and unpack Jena:
wget http://ftp.tsukuba.wide.ad.jp/software/apache//jena/binaries/apache-jena-${JENA_VERSION}.tar.gz
tar xzf apache-jena-${JENA_VERSION}.tar.gz
cd apache-jena-${JENA_VERSION}

