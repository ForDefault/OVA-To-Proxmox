#!/bin/bash

# Define path to settings.py
SETTINGS_PY="./settings.py"

# Function to ask for settings
ask_for_settings() {
    read -p "Enter the path to the OVA file: " ovaPath
    read -p "Enter the IP address of Proxmox hypervisor: " ipProxmox
    read -p "Enter Proxmox login username (default is root): " loginProxmox
    echo "Enter Proxmox login password (input will be hidden): "
    read -s passwordProxmox
    read -p "Enter SSH port (default is 22): " sshPort
    read -p "Enter the storage path on Proxmox (e.g., /mnt/example/): " storagePath

    # Create or overwrite settings.py with new values
    echo "ovaPath = r\"$ovaPath\"" > "$SETTINGS_PY"
    echo "ipProxmox = \"$ipProxmox\"" >> "$SETTINGS_PY"
    echo "loginProxmox = \"$loginProxmox\"" >> "$SETTINGS_PY"
    echo "passwordProxmox = \"$passwordProxmox\"" >> "$SETTINGS_PY"
    echo "sshPort = $sshPort" >> "$SETTINGS_PY"
    echo "storagePath = r\"$storagePath\"" >> "$SETTINGS_PY"
}

# Run the function to ask for settings
ask_for_settings

# Launch the main.py script
python3 main.py
