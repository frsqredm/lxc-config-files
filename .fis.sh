#!/bin/bash

fis_version="v1.0.5-b"

touch ~/.fis.log

# Edit pacman config
f-pacman() {
    printf "\nEditing pacman config ... " &>> ~/.fis.log
    tail -n 1 ~/.fis.log
    printf "\n"
    sed -i "s/#ParallelDownloads.*/ParallelDownloads = 10\nILoveCandy/" /etc/pacman.conf
    sed -i "s/#Color/Color/" /etc/pacman.conf
    sed -i "s/#DisableSandbox/DisableSandbox/" /etc/pacman.conf
    printf "\n[OK] Pacman config done!" &>> ~/.fis.log
    tail -n 1 ~/.fis.log
    printf "\n"
    sleep 2
}

export -f f-pacman && bash -c f-pacman

# Initialize the keyring
f-keyring() {
    printf "\nInitializing the keyring ... " &>> ~/.fis.log
    tail -n 1 ~/.fis.log
    printf "\n"
    rm -rf /etc/pacman.d/gnupg
    pacman-key --init &>> ~/.fis.log
    pacman-key --populate &>> ~/.fis.log
    pacman -Sy --noconfirm archlinux-keyring &>> ~/.fis.log
    pacman -Su --noconfirm &>> ~/.fis.log
    printf "\n[OK] Keyring done!" &>> ~/.fis.log
    tail -n 1 ~/.fis.log
    printf "\n"
}

export -f f-keyring && bash -c f-keyring

# Install gum and reflector
printf "\nInstalling gum and reflector ... " &>> ~/.fis.log
tail -n 1 ~/.fis.log
printf "\n"
pacman -S --noconfirm --needed gum reflector &>> ~/.fis.log
printf "\n[OK] Gum and reflector installed!" &>> ~/.fis.log
tail -n 1 ~/.fis.log
printf "\n"
sleep 2

# Enable reflector
f-reflector() {
    sed -i "s/# --country.*/--country SG,HK,VN/" /etc/xdg/reflector/reflector.conf &>> ~/.fis.log
    sed -i "s/--latest 5/--latest 10/" /etc/xdg/reflector/reflector.conf &>> ~/.fis.log
    sed -i "s/--sort age/--sort rate/" /etc/xdg/reflector/reflector.conf &>> ~/.fis.log
    systemctl enable --now reflector.timer &>> ~/.fis.log
    systemctl start reflector.service &>> ~/.fis.log
    printf "\n[OK] Reflector started!" &>> ~/.fis.log
    tail -n 1 ~/.fis.log
    printf "\n"
    sleep 2
}

export -f f-reflector
gum spin --spinner minidot --show-error --title="Enabling reflector ... " -- bash -c f-reflector

# Introduction
gum style \
	    --border normal \
	    --align left --width 60 --margin "0 0" --padding "0 0" \
	    "FIS Install Script" \
        "1. Install essential packages: pacman-contrib zsh git unzip postgresql wget" \
        "2. Install more packages: reflector python fzf zoxide" \
        "3. Git config" \
        "4. Install: OMP, nodeJS, bunJS" \
        "5. Get config file for zsh, OMP"

printf "\nContinue ? \n"
ANS=$(gum choose {yes,no})
printf "\n"

# Install packages
f-packages() {
    pacman -S --noconfirm --needed base-devel pacman-contrib libffi \
        man zsh git unzip wget fzf zoxide postgresql postgresql-libs \
        python-pip python-pipx &>> ~/.fis.log
    systemctl enable --now paccache.timer &>> ~/.fis.log
    printf "\n[OK] Essential packages installed!" &>> ~/.fis.log
    tail -n 1 ~/.fis.log
    printf "\n"
    sleep 2
}

# Config git
f-git() {
    git config --global user.name frsqredm
    git config --global user.email fr.sqre.dm@gmail.com
    git config --global credential.helper "cache --timeout=604800"
    git config --global init.defaultBranch main
    printf "\n[OK] Config git as frsqredm done!" &>> ~/.fis.log
    tail -n 1 ~/.fis.log
    printf "\n"
    sleep 2
}

# Install OMP, nodeJS, bunJS
f-extra() {
    curl -s https://ohmyposh.dev/install.sh | bash -s &>> ~/.fis.log
    printf "\n[OK] Oh-my-posh installed!" &>> ~/.fis.log
    tail -n 1 ~/.fis.log
    printf "\n"
    sleep 1
    curl -fsSL https://fnm.vercel.app/install | bash &>> ~/.fis.log
    curl -fsSL https://bun.sh/install | bash &>> ~/.fis.log
    source ~/.bashrc &>> ~/.fis.log
    fnm use --install-if-missing 22 &>> ~/.fis.log
    printf "\n[OK] NodeJS $(node -v) installed!" &>> ~/.fis.log
    tail -n 1 ~/.fis.log
    printf "\n"
    printf "\n[OK] BunJS v$(bun -v) installed!" &>> ~/.fis.log
    tail -n 1 ~/.fis.log
    printf "\n"
    sleep 2
}

# Get config file for zsh, OMP
f-config() {
    # Asume code-server already installed
    cp -r ~/.config/code-server ~/code-server-backup &>> ~/.fis.log
    rm -rf ~/.config &>> ~/.fis.log # Remove existing .config folder 
    git clone https://github.com/frsqredm/lxc-config-files.git ~/.config &>> ~/.fis.log
    cp -r ~/code-server-backup ~/.config/code-server &>> ~/.fis.log
    rm -rf ~/code-server-backup &>> ~/.fis.log
    rm ~/.zshrc &>> ~/.fis.log # Remove existing .zshrc file
    ln -s ~/.config/zsh/.zshrc ~/.zshrc &>> ~/.fis.log
    printf "\n[OK] Config files save at ~/.config !" &>> ~/.fis.log
    tail -n 1 ~/.fis.log
    printf "\n"
    sleep 2
}

# Finish
f-finish() {
    printf "\n[OK] FIS Install Script finished !! \n"
    printf "\nTODO: 
    1. Change default shell by chsh and exec zsh.
    2. Review and delete .fis.log file. \n"
    rm ~/.fis.sh &>> ~/.fis.log
    sleep 2
}

# Cancell script
f-cancell () {
    gum spin --spinner minidot --title="Cancelling script ..." -- sleep 2
    printf "\n[OK] Script cancelled! \n"
    printf "\nSee you later! \n"
    rm ~/.fis.sh &>> ~/.fis.log
    sleep 2
}

if [ "$ANS" == "yes" ]; then
    export -f f-packages f-git f-extra f-config f-finish &&
    gum spin --spinner minidot --show-output --title="Install essential packages ... " -- bash -c f-packages &&
    gum spin --spinner minidot --show-output --title="Config git ... " -- bash -c f-git &&
    gum spin --spinner minidot --show-output --title="Install OMP, nodeJS, bunJS ... " -- bash -c f-extra &&
    gum spin --spinner minidot --show-output --title="Getting config files for zsh, OMP ... " -- bash -c f-config &&
    bash -c f-finish
else
    export -f f-cancell && bash -c f-cancell
fi