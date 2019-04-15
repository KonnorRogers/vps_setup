#!/bin/sh

sudo apt-get install maven openjdk-11-jdk -y

export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
export M2_HOME=/usr/share/maven
export PATH=$JAVA_HOME/bin:$M2_HOME/bin:$PATH

SERVER="$HOME/bastillion_server"
echo "Creating a bastillion_server directory @ $SERVER"
mkdir -p "$SERVER"

LMVC="$SERVER/lmvc"
git clone https://github.com/bastillion-io/lmvc.git "$LMVC"
cd "$LMVC"
mvn clean package install

BASTILLION="$SERVER/Bastillion"
git clone https://github.com/bastillion-io/Bastillion.git
cd "$BASTILLION"

export BASTILLION_HOME="$BASTILLION"

# src/main/resources/BastillionConfig.properties contains config info

echo "Run the following command from the this directory"
echo "mvn package jetty:run"

echo "open browser to 'https://<ip>:8443'"
echo "username:admin"
echo "password:changeme"

# username:admin
# password:changeme


# Various other setup stuff
