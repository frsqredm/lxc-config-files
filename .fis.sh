#!/bin/bash

fis_version="1.0.0"

# Install gum
printf "\nInstalling gum ... \n"
pacman -S --noconfirm gum
printf "\n[ \u2714 ] done\n"
sleep 2

# Edit pacman config
f0() {
    sed -i "s/#ParallelDownloads.*/ParallelDownloads = 10\nILoveCandy/" /etc/pacman.conf
    sleep 1
    sed -i "s/#Color/Color/" /etc/pacman.conf
    sleep 1
    sed -i "s/#DisableSandbox/DisableSandbox/"
    sleep 1
    printf "\n[ \u2714 ] done\n"
    sleep 2
}

export -f f0
gum spin --spinner minidot --show-error --title="Editing pacman config ..." -- \
    bash -c f0

# Initialize the keyring
f1() {
    rm -rf /etc/pacman.d/gnupg
    pacman-key --init
    pacman-key --populate
    pacman -Sy --noconfirm archlinux-keyring
    pacman -Su --noconfirm
}

export -f f1
gum spin --spinner minidot --show-error --title="Initializing the keyring ... " -- bash -c f1

# Introduction
gum style \
	    --border normal \
	    --align left --width 60 --margin "0 0" --padding "0 0" \
	    "FIS Install Script" \
        "1. Install essential packages: zsh git tree unzip postgresql wget curl fzf zoxide" \
        "2. Git config" \
        "3. Install: OMP, nodeJS, bunJS" \
        "4. Get config file for zsh, OMP"

printf "\nContinue ? \n"
ANS=$(gum choose {yes,no})

# Install packages
f2() {
    pacman -S --noconfirm zsh pacman-contrib git tree unzip wget fzf zoxide postgresql postgresql-libs
    systemctl enable --now paccache.timer
    sleep 2
    printf "\n[ \u2714 ] done\n"
    sleep 2
}

# Config git
f3() {
    git config --global user.name frsqredm
    git config --global user.email fr.sqre.dm@gmail.com
    git config --global credential.helper "cache --timeout=604800"
    git config --global init.defaultBranch main
    sleep 2
    printf "\n[ \u2714 ] done config git as frsqredm\n"
    sleep 2
}

# Install OMP, nodeJS, bunJS
f4() {
    curl -s https://ohmyposh.dev/install.sh | bash -s
    printf "\n[ \u2714 ] oh-my-posh v$(oh-my-posh version) installed\n"
    sleep 1
    curl -fsSL https://fnm.vercel.app/install | bash
    curl -fsSL https://bun.sh/install | bash
    source ~/.bashrc
    fnm use --install-if-missing 22
    printf "\n[ \u2714 ] nodeJS $(node -v) installed\n"
    sleep 2
    printf "\n[ \u2714 ] bunJS v$(bun -v) installed\n"
    sleep 2
}

# Get config file for zsh, OMP
f5() {
    # Asume code-server already installed
    cp -r ~/.config/code-server ~/code-server-backup
    rm -rf ~/.config # Remove existing .config folder
    git clone https://github.com/frsqredm/lxc-config-files.git ~/.config
    cp -r ~/code-server-backup ~/.config/code-server
    rm -rf ~/code-server-backup
    rm ~/.zshrc # Remove existing .zshrc file
    ln -s ~/.config/zsh/.zshrc ~/.zshrc
    printf "\n[ \u2714 ] config files save at ~/.config\n"
    sleep 2
}

# Finish
f6() {
    printf "\n[ \u2714 ] FIS Install Script $fis_version finished !! \n"
    printf "\nTODO: chsh and exec zsh to change default shell to zsh"
    rm ~/.fis.sh
    sleep 2
}

# Cancell script
f7 () {
    printf "\nSee you later! \n"
    rm ~/.fis.sh
    sleep 2
}

if [ "$ANS" == "yes" ]; then
    export -f f2 f3 f4 f5 f6 &&
    gum spin --spinner minidot --show-error --title="Install essential packages ... " -- bash -c f2 &&
    gum spin --spinner minidot --show-error --title="Config git ... " -- bash -c f3 &&
    gum spin --spinner minidot --show-error --title="Install OMP, nodeJS, bunJS ... " -- bash -c f4 &&
    gum spin --spinner minidot --show-error --title="Getting config files for zsh, OMP ... " -- bash -c f5 &&
    bash -c f6
else
    export -f f7 && bash -c f7
fi