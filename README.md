Hi! I made this installer to help Linux newbies easily install, reinstall, or uninstall Brave with a graphical interface using the terminal. It provides a user-friendly interface with robust error handling.

To install the installer, simply run:
```bash
#!/bin/bash

# URL of the installer script to download
installer_url="https://github.com/Rays-Robotics/Brave-Linux-Installer/raw/refs/heads/main/Linux-brave-installer.v1.sh"

# Name of the command to be installed
command_name="brave-install"

# Function to log messages
log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1"
}

# Download the installer script
log "Downloading the installer script from $installer_url..."
if wget -O "$command_name.sh" "$installer_url"; then
    log "Installer script downloaded successfully."
else
    log "Failed to download the installer script."
    exit 1
fi

# Make the installer script executable
log "Making the installer script executable..."
if chmod +x "$command_name.sh"; then
    log "Installer script made executable."
else
    log "Failed to make the installer script executable."
    exit 1
fi

# Move the installer script to /usr/local/bin and rename it
log "Installing the installer script as the command $command_name..."
if sudo mv "$command_name.sh" "/usr/local/bin/$command_name"; then
    log "Installer script installed successfully as $command_name."
else
    log "Failed to install the installer script."
    exit 1
fi

# Success message
log "Installation complete. You can now run the installer script with the command: $command_name"
