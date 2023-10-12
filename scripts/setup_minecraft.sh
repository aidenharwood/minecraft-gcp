#!/bin/bash

# BEGIN: 8f1j4d9c3j2
#!/bin/bash

# Check if /mnt/minecraft is mounted
if ! mountpoint -q /mnt/minecraft; then
    # Identify disks
    DISKS=($(lsblk -dpno NAME,SIZE,TYPE,MOUNTPOINT | grep -E 'disk *$' | awk '{print $1}'))

    # Check each disk for partitions
    for DISK in "${DISKS[@]}"; do
        # Check if there are partitions on the disk
        PARTITIONS=$(lsblk -dplno NAME,TYPE ${DISK} | grep part | wc -l)
        
        if [ "${PARTITIONS}" -eq "0" ]; then
            echo "Found unpartitioned disk: ${DISK}"
            
            # Formatting the disk to ext4
            echo "Formatting ${DISK} to ext4..."
            mkfs.ext4 "${DISK}"
            
            # Mount to /mnt/minecraft
            echo "Mounting ${DISK} to /mnt/minecraft..."
            mount "${DISK}" /mnt/minecraft

            # Add to fstab
            echo "Adding to /etc/fstab..."
            echo "${DISK}  /mnt/minecraft  ext4  defaults  0  2" >> /etc/fstab

            echo "Done."
        fi
    done
fi

echo "No unpartitioned disks found."

# Update the package list and install dependencies
sudo apt-get update
sudo apt-get install -y default-jdk screen jq

# Create a directory for the Minecraft server
cd /mnt/minecraft

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