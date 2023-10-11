#!/bin/bash

# Update the package list and install dependencies
sudo apt-get update
sudo apt-get install -y default-jdk screen

# Create a directory for the Minecraft server
mkdir ~/minecraft-server
cd ~/minecraft-server

# Download the Minecraft server jar file
wget -O server.jar https://launcher.mojang.com/v1/objects/$(curl -s https://launchermeta.mojang.com/mc/game/version_manifest.json | jq -r '.latest.release')/server.jar
# Accept the Minecraft EULA
echo "eula=true" > eula.txt

# Do any mod setup here

# Start the Minecraft server in a screen session
screen -S minecraft -dm java -Xmx1024M -Xms1024M -jar server.jar nogui