#!/bin/bash

# Minimum required RAM in MB
MIN_RAM=2048

# Function to log messages
log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1"
}

# Function to check if the system has enough RAM
check_ram() {
    total_ram=$(free -m | awk '/^Mem:/{print $2}')
    if [ "$total_ram" -lt "$MIN_RAM" ]; then
        log "Error: Not enough RAM. Minimum required is ${MIN_RAM}MB."
        exit 1
    else
        log "System has enough RAM: ${total_ram}MB."
    fi
}

# Function to detect the distribution and install Brave browser with error handling
install_brave() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        case "$ID" in
            ubuntu|debian)
                log "Detected distribution: $ID. Installing Brave browser..."
                if sudo apt update && sudo apt install -y apt-transport-https curl; then
                    if sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg; then
                        echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
                        if sudo apt update && sudo apt install -y brave-browser; then
                            log "Brave browser installed successfully on $ID."
                        else
                            log "Error: Failed to install Brave browser on $ID."
                            exit 1
                        fi
                    else
                        log "Error: Failed to download Brave browser keyring on $ID."
                        exit 1
                    fi
                else
                    log "Error: Failed to update and install dependencies on $ID."
                    exit 1
                fi
                ;;
            fedora)
                log "Detected distribution: Fedora. Installing Brave browser..."
                if sudo dnf install -y dnf-plugins-core; then
                    if sudo dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/x86_64/ && sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc; then
                        if sudo dnf install -y brave-browser; then
                            log "Brave browser installed successfully on Fedora."
                        else
                            log "Error: Failed to install Brave browser on Fedora."
                            exit 1
                        fi
                    else
                        log "Error: Failed to add Brave browser repo on Fedora."
                        exit 1
                    fi
                else
                    log "Error: Failed to install dnf plugins on Fedora."
                    exit 1
                fi
                ;;
            arch|manjaro)
                log "Detected distribution: $ID. Installing Brave browser..."
                if sudo pacman -S --needed base-devel; then
                    if git clone https://aur.archlinux.org/brave-bin.git; then
                        cd brave-bin || { log "Error: Failed to enter brave-bin directory."; exit 1; }
                        if makepkg -si; then
                            log "Brave browser installed successfully on $ID."
                        else
                            log "Error: Failed to build and install Brave browser on $ID."
                            exit 1
                        fi
                    else
                        log "Error: Failed to clone Brave browser repository on $ID."
                        exit 1
                    fi
                else
                    log "Error: Failed to install base-devel on $ID."
                    exit 1
                fi
                ;;
            *)
                log "Error: Unsupported distribution: $ID."
                exit 1
                ;;
        esac
    else
        log "Error: Could not detect the distribution."
        exit 1
    fi
}

# Function to uninstall Brave browser with error handling
uninstall_brave() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        case "$ID" in
            ubuntu|debian)
                log "Uninstalling Brave browser on $ID..."
                if sudo apt remove -y brave-browser; then
                    log "Brave browser uninstalled successfully on $ID."
                else
                    log "Error: Failed to uninstall Brave browser on $ID."
                    exit 1
                fi
                ;;
            fedora)
                log "Uninstalling Brave browser on Fedora..."
                if sudo dnf remove -y brave-browser; then
                    log "Brave browser uninstalled successfully on Fedora."
                else
                    log "Error: Failed to uninstall Brave browser on Fedora."
                    exit 1
                fi
                ;;
            arch|manjaro)
                log "Uninstalling Brave browser on $ID..."
                if sudo pacman -Rns brave-bin; then
                    log "Brave browser uninstalled successfully on $ID."
                else
                    log "Error: Failed to uninstall Brave browser on $ID."
                    exit 1
                fi
                ;;
            *)
                log "Error: Unsupported distribution: $ID."
                exit 1
                ;;
        esac
    else
        log "Error: Could not detect the distribution."
        exit 1
    fi
}

# Function to prompt the user for action
prompt_user() {
    choice=$(whiptail --title "Brave Browser Installer" --menu "Choose an option:" 15 60 3 \
    "1" "Install Brave Browser" "2" "Reinstall Brave Browser" "3" "Uninstall Brave Browser" 3>&1 1>&2 2>&3)

    case $choice in
        1)
            check_ram
            install_brave
            log "Brave browser installation complete."
            ;;
        2)
            uninstall_brave
            check_ram
            install_brave
            log "Brave browser reinstallation complete."
            ;;
        3)
            uninstall_brave
            ;;
        *)
            log "Invalid option selected."
            exit 1
            ;;
    esac

    # Ask if the user wants to delete the installer script
    if whiptail --yesno "Do you want to delete the installer script?" 10 60; then
        log "Deleting the installer script..."
        rm -- "$0"
        log "Installer script deleted."
    else
        log "Installer script not deleted."
    fi
}

# Run the prompt
prompt_user
