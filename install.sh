#! /bin/bash
reflector_init() {
    reflector_install_status="pacman -Qs reflector"
    if [ -n "$reflector_install_status" ]; then
        echo "${GREEN}Reflector is installed"
        echo "${YELLOW}Configuring Reflector"
        sudo reflector --verbose -c AT -c BY -c BE -c BA -c BG -c DK -c FI -c FR -c GE -c DE -c GR -c IE -c LU -c MC -c NL -c NO -c ES -c SE -c CH -c GB --protocol score --sort score --latest 10 --download-timeout 5 --save /etc/pacman.d/mirrorlist >/dev/null
    else
        echo "${RED}Reflector is not installed"
        sudo pacman -S reflector --noconfirm >/dev/null
        reflector_install_status="pacman -Qs reflector"
        if [ -n "$reflector_install_status" ]; then
            echo "${GREEN}Reflector installed successfully"
            echo "${YELLOW}Configuring Reflector"
            sudo reflector --verbose -c AT -c BY -c BE -c BA -c BG -c DK -c FI -c FR -c GE -c DE -c GR -c IE -c LU -c MC -c NL -c NO -c ES -c SE -c CH -c GB --protocol score --sort score --latest 10 --download-timeout 5 --save /etc/pacman.d/mirrorlist >/dev/null
        else
            exit
        fi
    fi
}

gitconfig_init() {
    echo -n "Username for git config: "
    read username
    echo -n "Email for git config " email
    read email
    git config --global user.name "$username" >/dev/null
    git config --global user.email "$email" >/dev/null
}
git_init() {
    git_install_status="pacman -Qs git"
    if [ -n "$git_install_status" ]; then
        echo "${GREEN}Git is installed"
        gitconfig_init
    else
        echo "${RED}Git is not installed"
        echo "${YELLOW}Installing Git"
        sudo pacman -S git --noconfirm >/dev/null
        if [ -n "$git_install_status" ]; then
            echo "${GREEN}Git installed successfully"
            echo "${YELLOW}Configuring Git"
            gitconfig_init
        else
            exit
        fi

        gitconfig_init
    fi

}
