#!/bin/bash

MOUNT="/mnt/minecraft"

# Check if $MOUNT is mounted
if ! mountpoint -q $MOUNT; then
    # Identify disks
    DISKS=($(lsblk -dpno NAME,SIZE,TYPE,MOUNTPOINT | grep -E 'disk *$' | awk '{print $1}'))

    # Check each disk for partitions
    for DISK in "${DISKS[@]}"; do
        # Check if there are partitions on the disk
        PARTITIONS=$(lsblk -dplno NAME,TYPE $DISK | grep part | wc -l)
        
        if [ "${PARTITIONS}" -eq "0" ]; then
            echo "Found unpartitioned disk: $DISK"
            
            # Formatting the disk to ext4
            echo "Formatting $DISK to ext4..."
            mkfs.ext4 -F "$DISK"
            
            # Mount to $MOUNT
            echo "Mounting $DISK to $MOUNT..."
            [ ! -d $MOUNT ] && mkdir -p $MOUNT
            mount "$DISK" $MOUNT

            echo "Done."
        fi
    done
fi

# Update the package list and install dependencies
sudo apt-get update
sudo apt-get install -y default-jdk screen jq git htop

if mountpoint -q $MOUNT; then
    # Create a directory for the Minecraft server
    cd $MOUNT

    # Fetch the latest Minecraft version supported by PaperMC
    MC_VERSION=$(curl -s https://papermc.io/api/v2/projects/paper | jq -r '.versions[-1]')

    # Check if the version was successfully retrieved
    if [ -z "$MC_VERSION" ]; then
        echo "Failed to retrieve the latest Minecraft version supported by PaperMC."
        exit 1
    fi

    # Get the latest build number for the fetched MC version
    BUILD_NUMBER=$(curl -s https://papermc.io/api/v2/projects/paper/versions/${MC_VERSION} | jq -r '.builds[-1]')

    # Check if the build number was successfully retrieved
    if [ -z "$BUILD_NUMBER" ]; then
        echo "Failed to retrieve the latest build number for Minecraft version ${MC_VERSION}."
        exit 1
    fi

    # Download the latest PaperMC server JAR for the fetched MC version and build number
    DOWNLOAD_URL="https://papermc.io/api/v2/projects/paper/versions/${MC_VERSION}/builds/${BUILD_NUMBER}/downloads/paper-${MC_VERSION}-${BUILD_NUMBER}.jar"
    curl -o paper-latest.jar $DOWNLOAD_URL

    # Check if the JAR file was successfully downloaded
    if [ $? -eq 0 ]; then
        echo "Successfully downloaded the latest PaperMC server JAR for Minecraft version ${MC_VERSION}."
        # Accept the Minecraft EULA
        echo "eula=true" > eula.txt

        # Do any mod setup here
        #!/bin/bash

        # Navigate to the plugins directory
        cd /path/to/plugins/directory

        # Download the latest version of the Geyser plugin
        curl -o plugins/geyser.jar https://ci.opencollab.dev/job/GeyserMC/job/Geyser/job/master/lastSuccessfulBuild/artifact/bootstrap/spigot/build/libs/Geyser-Spigot.jar

        # Download the latest version of the Floodgates plugin
        curl -o plugins/floodgates.jar https://ci.opencollab.dev/job/GeyserMC/job/Floodgate/job/master/lastSuccessfulBuild/artifact/spigot/build/libs/floodgate-spigot.jar

        # Download the latest version of the mcMMO plugin
        curl -o plugins/mcmmo.jar https://popicraft.net/jenkins/job/mcMMO/lastSuccessfulBuild/artifact/target/mcMMO.jar

        # Start the Minecraft server in a screen session
        screen -S minecraft -dm java -Xmx2G -Xms2G -jar paper-latest.jar nogui
    else
        echo "Failed to download the PaperMC server JAR."
        exit 1
    fi
fi