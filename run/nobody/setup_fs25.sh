#!/bin/bash

. /usr/local/bin/wine_init.sh

# Check dlc's

if [ -f /opt/fs25/dlc/FarmingSimulator25_extraContentNewHollandCR11_*.exe ]; then
    echo -e "${GREEN}INFO: New Holland CR11 Gold Edition SETUP FOUND!${NOCOLOR}"
else
	echo -e "${YELLOW}WARNING: New Holland CR11 Gold Edition Setup not found, do you own it and does it exist in the dlc mount path?${NOCOLOR}"
	echo -e "${YELLOW}WARNING: If you do not own it ignore this!${NOCOLOR}"
fi

if [ -f /opt/fs25/dlc/FarmingSimulator25_macDonPack_*.exe ]; then
    echo -e "${GREEN}INFO: MacDon SETUP FOUND!${NOCOLOR}"
else
        echo -e "${YELLOW}WARNING: MacDon Setup not found, do you own it and does it exist in the dlc mount path?${NOCOLOR}"
        echo -e "${YELLOW}WARNING: If you do not own it ignore this!${NOCOLOR}"
fi

# it's important to check if the config directory exists on the host mount path. If it doesn't exist, create it.

if [ -d /opt/fs25/config/FarmingSimulator2025 ]
then
    echo -e "${GREEN}INFO: The host config directory exists, no need to create it!${NOCOLOR}"
else
mkdir -p /opt/fs25/config/FarmingSimulator2025

fi

# it's important to check if the game directory exists on the host mount path. If it doesn't exist, create it.

if [ -d /opt/fs25/game/Farming\ Simulator\ 2025 ]
then
    echo -e "${GREEN}INFO: The host game directory exists, no need to create it!${NOCOLOR}"
else
mkdir -p /opt/fs25/game/Farming\ Simulator\ 2025

fi

# Create Symlinks
. /usr/local/bin/wine_symlinks.sh

if [ -f ~/.fs25server/drive_c/Program\ Files\ \(x86\)/Farming\ Simulator\ 2025/FarmingSimulator2025.exe ]
then
    echo -e "${GREEN}INFO: Game already installed, we can skip the installer!${NOCOLOR}"
else
    wine "/opt/fs25/installer/FarmingSimulator2025.exe"
fi

# Cleanup Desktop

if [ -f ~/Desktop/ ]
then
    rm -r "~/Desktop/Farming\ Simulator\ 25\ .*"
else
    echo -e "${GREEN}INFO: Nothing to cleanup!${NOCOLOR}"
fi

# Do we have a license file installed?

count=`ls -1 ~/.fs25server/drive_c/users/$USER/Documents/My\ Games/FarmingSimulator2025/*.dat 2>/dev/null | wc -l`
if [ $count != 0 ]
then
    echo -e "${GREEN}INFO: Generating the game license files as needed!${NOCOLOR}"
else
    wine ~/.fs25server/drive_c/Program\ Files\ \(x86\)/Farming\ Simulator\ 2025/FarmingSimulator2025.exe
fi

count=`ls -1 ~/.fs25server/drive_c/users/$USER/Documents/My\ Games/FarmingSimulator2025/*.dat 2>/dev/null | wc -l`
if [ $count != 0 ]
then
    echo -e "${GREEN}INFO: The license files are in place!${NOCOLOR}"
else
    echo -e "${RED}ERROR: No license files detected, they are generated after you enter the cd-key during setup... most likely the setup is failing to start!${NOCOLOR}" && exit
fi

. /usr/local/bin/copy_server_config.sh


# Install DLC

if [ -f ~/.fs25server/drive_c/users/nobody/Documents/My\ Games/FarmingSimulator2025/pdlc/extraContentNewHollandCR11.dlc ]
then
    echo -e "${GREEN}INFO: New Holland CR11 Gold Edition already installed!${NOCOLOR}"
else
    if [ -f /opt/fs25/dlc/FarmingSimulator25_extraContentNewHollandCR11_*.exe ]; then
        echo -e "${GREEN}INFO: Installing New Holland CR11 Gold Edition!${NOCOLOR}"
        for i in /opt/fs25/dlc/FarmingSimulator25_extraContentNewHollandCR11*.exe; do wine "$i"; done
        echo -e "${GREEN}INFO: New Holland CR11 Gold Edition is now installed!${NOCOLOR}"
    fi
fi

if [ -f ~/.fs25server/drive_c/users/nobody/Documents/My\ Games/FarmingSimulator2025/pdlc/macDonPack.dlc ]
then
    echo -e "${GREEN}INFO: MacDon Pack is already installed!${NOCOLOR}"
else
    if [ -f /opt/fs25/dlc/FarmingSimulator25_macDonPack_*.exe ]; then
        echo -e "${GREEN}INFO: Installing MacDon Pack..!${NOCOLOR}"
        for i in /opt/fs25/dlc/FarmingSimulator25_macDonPack*.exe; do wine "$i"; done
        echo -e "${GREEN}INFO: MacDon Pack is now installed!${NOCOLOR}"
    fi
fi


# Check for updates

echo -e "${YELLOW}INFO: Checking for updates, if you get warning about gpu drivers make sure to click no!${NOCOLOR}"
wine ~/.fs25server/drive_c/Program\ Files\ \(x86\)/Farming\ Simulator\ 2025/FarmingSimulator2025.exe

# Check config if not exist exit

if [ -f ~/.fs25server/drive_c/users/$USER/Documents/My\ Games/FarmingSimulator2025/dedicated_server/dedicatedServerConfig.xml ]
then
    echo -e "${GREEN}INFO: We can run the server now by clicking on 'Start Server' on the desktop!${NOCOLOR}"
else
    echo -e "${RED}ERROR: We are missing files?${NOCOLOR}" && exit
fi

. /usr/local/bin/cleanup_logs.sh

echo -e "${YELLOW}INFO: Checking for updates, if you get warning about gpu drivers make sure to click no!${NOCOLOR}"
wine ~/.fs25server/drive_c/Program\ Files\ \(x86\)/Farming\ Simulator\ 2025/FarmingSimulator2025.exe

echo -e "${YELLOW}INFO: All done, closing this window in 20 seconds...${NOCOLOR}"

exec sleep 20
