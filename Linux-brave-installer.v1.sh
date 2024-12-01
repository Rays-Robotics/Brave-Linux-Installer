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

# Function to detect the distribution and install Brave browser
install_brave() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        case "$ID" in
            ubuntu|debian)
                log "Detected distribution: $ID. Installing Brave browser..."
                sudo apt update
                sudo apt install -y apt-transport-https curl
                sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
                echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
                sudo apt update
                sudo apt install -y brave-browser
                ;;
            fedora)
                log "Detected distribution: Fedora. Installing Brave browser..."
                sudo dnf install -y dnf-plugins-core
                sudo dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/x86_64/
                sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
                sudo dnf install -y brave-browser
                ;;
            arch|manjaro)
                log "Detected distribution: $ID. Installing Brave browser..."
                sudo pacman -S --needed base-devel
                git clone https://aur.archlinux.org/brave-bin.git
                cd brave-bin
                makepkg -si
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

# Function to uninstall Brave browser
uninstall_brave() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        case "$ID" in
            ubuntu|debian)
                log "Uninstalling Brave browser on $ID..."
                sudo apt remove -y brave-browser
                ;;
            fedora)
                log "Uninstalling Brave browser on Fedora..."
                sudo dnf remove -y brave-browser
                ;;
            arch|manjaro)
                log "Uninstalling Brave browser on $ID..."
                sudo pacman -Rns brave-bin
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
    log "Brave browser uninstallation complete."
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
}

# Run the prompt
prompt_user
