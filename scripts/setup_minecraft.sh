#!/bin/bash

# Update the package list and install dependencies
sudo apt-get update
sudo apt-get install -y default-jdk screen jq

# Create a directory for the Minecraft server
mkdir ~/minecraft-server
cd ~/minecraft-server

jarUrl=$(curl -s https://launchermeta.mojang.com/mc/game/version_manifest.json \
    | jq -r '.latest.release as $release | .versions[] | select(.id==$release) | .url' \
    | while read -r url; do curl -s $url; done \
    | jq -r '.downloads.server.url')

# Download the Minecraft server jar file
wget -O server.jar $jarUrl
# Accept the Minecraft EULA
echo "eula=true" > eula.txt

# Do any mod setup here

# Start the Minecraft server in a screen session
screen -S minecraft -dm java -Xmx2G -Xms2G -jar server.jar nogui