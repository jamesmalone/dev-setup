#!/usr/bin/env bash

# Installs, configures, and starts Hadoop.

set -e

# START OF SETTINGS SECTION
#
# Script based on: http://www.uni-koblenz-landau.de/campus-koblenz/fb4/west/teaching/ss14/data-science/HadoopLinux

# Proxy settings -- leave empty if no proxy is needed:
#
# Example: PROXY_HTTP=http://proxy.yourcompany.com:8080
PROXY_HTTP=
PROXY_HTTPS=$PROXY_HTTP

# Protobuf, Hadoop, etc., and data directories will go here:
#
# NOTE: directory is relative to home (~/), so "src" will be
#       referring to the directory "~/src"
SRC_BASE=src

# Default Java home -- if JAVA_VERSION is set below, then that
# particular JRE will be installed and JAVA_HOME will be overwritten:
export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64

# If JAVA_VERSION is set, then that particular JRE will be installed
# and JAVA_HOME will be reset to that installation.
PROTOBUF_VERSION=2.5.0
HADOOP_VERSION=2.5.1
# For example: JAVA_VERSION=java-7-oracle
JAVA_VERSION=

# END OF SETTINGS SECTION

# Set proxy environment variables -- if necessary:
if [[ "" != "$PROXY_HTTP" ]] ; then
    PROXY_ENV="http_proxy=$PROXY_HTTP"
    PROXY_ENVS="http_proxy=$PROXY_HTTPS"
else
    PROXY_ENV=
    PROXY_ENVS=
fi

# Update system first, then install required software packages:
sudo $PROXY_ENV $PROXY_ENVS apt-get update
sudo $PROXY_ENV $PROXY_ENVS apt-get install -y wget
sudo $PROXY_ENV $PROXY_ENVS apt-get install -y openssh-server
sudo $PROXY_ENV $PROXY_ENVS apt-get install -y build-essential
sudo $PROXY_ENV $PROXY_ENVS apt-get install -y software-properties-common
sudo $PROXY_ENV $PROXY_ENVS apt-get install -y python-software-properties

# Permit the installation of an alternative Java version.
# Default on Ubuntu will be OpenJDK.
#
# TODO Does not seem to work behind a HTTP/HTTPS proxy!?
if [[ "" != "$JAVA_VERSION" ]] ; then
    sudo $PROXY_ENV $PROXY_ENVS add-apt-repository ppa:webupd8team/java
    sudo $PROXY_ENV $PROXY_ENVS apt-get update
    sudo $PROXY_ENV $PROXY_ENVS apt-get install -y oracle-java7-installer
    export JAVA_HOME="/usr/lib/jvm/$JAVA_VERSION"
fi

# Does the source base directory exist? No? Well, create it!
cd ~
if [[ ! -d "$SRC_BASE" ]] ; then
    mkdir "$SRC_BASE"
fi
cd "$SRC_BASE"

# Get protobuf, build, install:
wget https://protobuf.googlecode.com/files/protobuf-${PROTOBUF_VERSION}.tar.gz
tar xzf protobuf-${PROTOBUF_VERSION}.tar.gz
cd protobuf-$PROTOBUF_VERSION
./configure
make
make check
sudo make install
sudo ldconfig

# Get Hadoop, build, install:
cd ~
cd "$SRC_BASE"
wget http://mirror.dkd.de/apache/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz
tar xzf hadoop-${HADOOP_VERSION}.tar.gz
cd hadoop-$HADOOP_VERSION
export HADOOP_HOME=`pwd`

# TODO? Ignore for now.
#sudo echo "" >> /etc/environment
#sudo echo "JAVA_HOME=/usr/lib/jvm/$JAVA_VERSION" >> /etc/environment
#sudo echo "HADOOP_HOME=$HADOOP_HOME" >> /etc/environment
#sudo echo "PATH=\$PATH:\$HADOOP_HOME/bin:\$HADOOP_HOME/sbin"

# Write out Hadoop configuration files:
echo '<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
<property>
    <name>fs.defaultFS</name>
    <value>hdfs://localhost:9000</value>
</property>
</configuration>' > $HADOOP_HOME/etc/hadoop/core-site.xml
echo '<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
<property>
    <name>dfs.replication</name>
    <value>1</value>
</property>
<property>
    <name>dfs.namenode.name.dir</name>
    <value>file:'$HADOOP_HOME'/data/dfs/namenode</value>
</property>
<property>
    <name>dfs.datanode.data.dir</name>
    <value>file:'$HADOOP_HOME'/data/dfs/datanode</value>
</property>
</configuration>' > $HADOOP_HOME/etc/hadoop/hdfs-site.xml
echo '<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
<property>
    <name>yarn.nodemanager.aux-services</name>
    <value>mapreduce_shuffle</value>
</property>
<property>
    <name>yarn.nodemanager.aux-services.mapreduce.shuffle.class</name>
    <value>org.apache.hadoop.mapred.ShuffleHandler</value>
</property>
<property>
    <name>yarn.application.classpath</name>
    <value>
        $HADOOP_HOME/etc/hadoop,
        $HADOOP_HOME/share/hadoop/common/*,
        $HADOOP_HOME/share/hadoop/common/lib/*,
        $HADOOP_HOME/share/hadoop/mapreduce/*,
        $HADOOP_HOME/share/hadoop/mapreduce/lib/*,
        $HADOOP_HOME/share/hadoop/hdfs/*,
        $HADOOP_HOME/share/hadoop/hdfs/lib/*,            
        $HADOOP_HOME/share/hadoop/yarn/*,
        $HADOOP_HOME/share/hadoop/yarn/lib/*
    </value>
</property>
</configuration>' > $HADOOP_HOME/etc/hadoop/yarn-site.xml
echo '<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
<property>
    <name>mapreduce.framework.name</name>
    <value>yarn</value>
</property>
</configuration>' > $HADOOP_HOME/etc/hadoop/mapred-site.xml

# Create data directories as specified in the configuration files above:
mkdir -p "$HADOOP_HOME/data/dfs/namenode"
mkdir -p "$HADOOP_HOME/data/dfs/datanode"

# Format HDFS (will warn and need user confirmation, if HDFS has been formatted beforehand already):
${HADOOP_HOME}/bin/hdfs namenode -format

# Explicitly set JAVA_HOME in the Hadoop environment settings script:
cp ${HADOOP_HOME}/etc/hadoop/hadoop-env.sh ${HADOOP_HOME}/etc/hadoop/hadoop-env.backup
gawk -F '=' '/^export JAVA_HOME/ {print "export JAVA_HOME='$JAVA_HOME'";} !/^export JAVA_HOME/ {print $0;}' ${HADOOP_HOME}/etc/hadoop/hadoop-env.backup > ${HADOOP_HOME}/etc/hadoop/hadoop-env.sh

# Start Hadoop:
$HADOOP_HOME/sbin/start-dfs.sh
$HADOOP_HOME/sbin/start-yarn.sh

