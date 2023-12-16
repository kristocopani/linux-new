#! /bin/bash
#Colors
# shellcheck disable=SC2034
BLUE=$(tput setaf 4)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
#Bold
BBLUE=$(
    tput bold
    tput setaf 4
)
BRED=$(
    tput bold
    tput setaf 1
)
BGREEN=$(
    tput bold
    tput setaf 2
)

#Functions

reflector_init() {
    echo "${BBLUE}Backing up /etc/pacman.d/mirrorlist to /etc/pacman.d/mirrorlist.backup"
    sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup >/dev/null
    sudo curl -s "https://archlinux.org/mirrorlist/?country=all&protocol=http&protocol=https&ip_version=4" | sudo tee /etc/pacman.d/mirrorlist >/dev/null
    sudo sed -i 's/^#Server/Server/' /etc/pacman.d/mirrorlist >/dev/null
}

reflector_install_init() {
    # shellcheck disable=SC2143
    if [ "$(sudo pacman -Q | grep "^reflector ")" ]; then
        echo "${GREEN}Reflector is installed"
        echo "${YELLOW}Configuring Reflector"
        sudo reflector --verbose -c AT -c BY -c BE -c BA -c BG -c DK -c FI -c FR -c GE -c DE -c GR -c IE -c LU -c MC -c NL -c NO -c ES -c SE -c CH -c GB --protocol https --sort score --latest 10 --download-timeout 5 --save /etc/pacman.d/mirrorlist >/dev/null
    else
        echo "${RED}Reflector is not installed"
        echo "${BBLUE}Installing Reflector."
        sudo pacman -S reflector --noconfirm >/dev/null
        if [ "$(sudo pacman -Q | grep "^reflector ")" ]; then
            echo "${GREEN}Reflector installed successfully"
            echo "${YELLOW}Configuring Reflector"
            sudo reflector --verbose -c AT -c BY -c BE -c BA -c BG -c DK -c FI -c FR -c GE -c DE -c GR -c IE -c LU -c MC -c NL -c NO -c ES -c SE -c CH -c GB --protocol https --sort score --latest 10 --download-timeout 5 --save /etc/pacman.d/mirrorlist >/dev/null
        else
            echo "${RED}Reflector failed to install."
            exit
        fi
    fi
}

gitconfig_init() {
    echo -n "Username for git config: "
    # shellcheck disable=SC2162
    read username
    echo -n "Email for git config: "
    # shellcheck disable=SC2162
    read email
    git config --global user.name "$username" >/dev/null
    git config --global user.email "$email" >/dev/null
}

git_init() {
    # shellcheck disable=SC2143
    if [ "$(sudo pacman -Q | grep "^git ")" ]; then
        echo "${GREEN}Git already installed."
        echo "${YELLOW}Configuring Git."
        gitconfig_init
    else
        echo "${RED}Git is not installed."
        echo "${BBLUE}Installing Git."
        sudo pacman -S git --noconfirm >/dev/null
        # shellcheck disable=SC2143
        if [ "$(sudo pacman -Q | grep "^git ")" ]; then
            echo "${GREEN}Git already installed."
            echo "${YELLOW}Configuring Git."
            gitconfig_init
        else
            echo "${RED}Git failed to install."
            exit
        fi

    fi
}

enable_bluetooth_init() {
    echo "${GREEN}Enabling bluetooth"
    sudo systemctl enable bluetooth -q
    sudo systemctl start bluetooth -q
    STATUS1="$(systemctl is-active bluetooth)"
    STATUS2="$(systemctl is-enabled bluetooth)"
    if [ "${STATUS1}" = "active" ] && [ "${STATUS2}" = "enabled" ]; then
        echo "${GREEN}Bluetooth started and enabled."
    elif [ "${STATUS1}" = "active" ] && [ "${STATUS2}" = "disabled" ]; then
        echo "${BLUE}Bluetooth started. Could not enable it."
    elif [ "${STATUS1}" = "inactive" ] && [ "${STATUS2}" = "enabled" ]; then
        echo "${BLUE}Bluetooth enabled but could not start."
    elif [ "${STATUS1}" = "inactive" ] && [ "${STATUS2}" = "disabled" ]; then
        echo "${RED}Bluetooth could not stand and is disabled."
    fi
}

install_yay() {
    echo "${BGREEN}Installing yay"
    echo "${GREEN}Checking if dependencies are installed."
    # shellcheck disable=SC2143
    if [ "$(sudo pacman -Q | grep "^base-devel ")" ]; then
        echo "${GREEN}Yay dependencies are installed"
    else
        echo "${GREEN}Installing Yay dependencies"
        sudo pacman -S --needed git base-devel --noconfirm >/dev/null
    fi

    # shellcheck disable=SC2164
    # shellcheck disable=SC2086
    cd $HOME
    git clone https://aur.archlinux.org/yay.git --quiet
    # shellcheck disable=SC2164
    # shellcheck disable=SC2086
    cd yay
    echo "${GREEN}Building and installing yay"
    makepkg -si --noconfirm --needed --noprogressbar --rmdeps --clean 1>/dev/null
    # shellcheck disable=SC2143
    if [ "$(sudo pacman -Q | grep "^yay")" ]; then
        echo "${BGREEN}Yay installed successfully"
    else
        echo "${BRED}Yay failed to install"
    fi
}

set_preferences() {
    echo "Defaults      editor=/usr/bin/rnano, !env_editor" | sudo tee -a /etc/sudoers
    echo "christos ALL=(ALL:ALL) NOPASSWD:/usr/bin/reboot,/usr/bin/shutdown,/usr/bin/pacman" | sudo tee -a /etc/sudoers
    yay --save --answerdiff None --answerclean None --removemake --editmenu=false --cleanmenu=false --cleanafter=true --answeredit None
    #curl -s "" | tee ~\.bashrc

}

install_lutris() {
    sudo pacman -Syyu --noconfirm >/dev/null
    sudo pacman -S lutris --noconfirm >/dev/null
    sudo pacman -S --needed nvidia-open-dkms nvidia-utils lib32-nvidia-utils nvidia-settings vulkan-icd-loader lib32-vulkan-icd-loader --noconfirm >/dev/null
    sudo pacman -S --needed wine-staging giflib lib32-giflib libpng lib32-libpng libldap lib32-libldap gnutls lib32-gnutls mpg123 lib32-mpg123 openal lib32-openal v4l-utils lib32-v4l-utils libpulse lib32-libpulse libgpg-error lib32-libgpg-error alsa-plugins lib32-alsa-plugins alsa-lib lib32-alsa-lib libjpeg-turbo lib32-libjpeg-turbo sqlite lib32-sqlite libxcomposite lib32-libxcomposite libxinerama lib32-libgcrypt libgcrypt lib32-libxinerama ncurses lib32-ncurses ocl-icd lib32-ocl-icd libxslt lib32-libxslt libva lib32-libva gtk3 lib32-gtk3 gst-plugins-base-libs lib32-gst-plugins-base-libs vulkan-icd-loader lib32-vulkan-icd-loader --noconfirm >/dev/null
}

enable_multilib() {
    sudo sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf
}

install() {
    sudo pacman -S linux-firmware --noconfirm >/dev/null
    yay -S visual-studio-code-bin --noconfirm >/dev/null
    yay -S ulauncher --noconfirm >/dev/null
}

set_preferences