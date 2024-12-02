#!/bin/bash

fis_version="v1.1.0-b"

f-begin() {
    printf "FIS Install Script starting ..." | tee -a ~/.fis.log
}

export -f f-begin && bash -c f-begin

# Edit pacman config
f-pacman() {
    printf "\nEditing pacman config ..." | tee -a ~/.fis.log
    sed -i "s/#ParallelDownloads.*/ParallelDownloads = 10\nILoveCandy/" /etc/pacman.conf
    sed -i "s/#Color/Color/" /etc/pacman.conf
    sed -i "s/#DisableSandbox/DisableSandbox/" /etc/pacman.conf
    printf "\n[OK] Pacman config done!" | tee -a ~/.fis.log
    sleep 2
}

export -f f-pacman && bash -c f-pacman
unset -f f-pacman

# Initialize the keyring
f-keyring() {
    printf "\nInitializing the keyring ..." | tee -a ~/.fis.log
    rm -rf /etc/pacman.d/gnupg
    pacman-key --init | tee -a ~/.fis.log
    pacman-key --populate | tee -a ~/.fis.log
    pacman -Sy --noconfirm archlinux-keyring | tee -a ~/.fis.log
    pacman -Su --noconfirm | tee -a ~/.fis.log
    printf "\n[OK] Keyring done!" | tee -a ~/.fis.log
}

export -f f-keyring && bash -c f-keyring
unset -f f-keyring

# Install gum and reflector
f-gum() {
    printf "\nInstalling gum and reflector ..." | tee -a ~/.fis.log
    pacman -S --noconfirm --needed gum reflector | tee -a ~/.fis.log
    printf "\n[OK] Gum and reflector installed!" | tee -a ~/.fis.log
    sleep 2
}

export -f f-gum && bash -c f-gum
unset -f f-gum

# Enable reflector
f-reflector() {
    gum log --file ~/.fis.log --time DateTime --level info "Enabling reflector ..."
    sed -i "s/# --country.*/--country SG,HK,VN/" /etc/xdg/reflector/reflector.conf
    sed -i "s/--latest 5/--latest 10/" /etc/xdg/reflector/reflector.conf
    sed -i "s/--sort age/--sort rate/" /etc/xdg/reflector/reflector.conf
    systemctl enable --now reflector.timer | tee -a ~/.fis.log
    systemctl start reflector.service | tee -a ~/.fis.log
    gum log --file ~/.fis.log --time DateTime --level info "[OK] Reflector started!"
    gum log --time DateTime --level info "[OK] Reflector started!"
    sleep 2
    clear
}

export -f f-reflector
gum log --time DateTime --level info "Enabling reflector ..."
gum spin --spinner minidot --show-output --title="" -- bash -c f-reflector
unset -f f-reflector

# Introduction
gum style \
	    --border normal \
	    --align left --width $COLUMNS --margin "0 0" --padding "0 0" \
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
    gum log --file ~/.fis.log --time DateTime --level info "Installing essential packages ..."
    pacman -S --noconfirm --needed base-devel pacman-contrib libffi \
        man zsh git unzip wget fzf zoxide postgresql postgresql-libs \
        python-pip python-pipx | tee -a ~/.fis.log
    systemctl enable --now paccache.timer | tee -a ~/.fis.log
    gum log --file ~/.fis.log --time DateTime --level info "[OK] Essential packages installed!"
}

# Config git
f-git() {
    gum log --file ~/.fis.log --time DateTime --level info "Configuring git ..."
    git config --global user.name frsqredm
    git config --global user.email fr.sqre.dm@gmail.com
    git config --global credential.helper "cache --timeout=604800"
    git config --global init.defaultBranch main
    gum log --file ~/.fis.log --time DateTime --level info "[OK] Done config git as frsqredm!"
}

# Install OMP, nodeJS, bunJS
f-extra() {
    gum log --file ~/.fis.log --time DateTime --level info "Installing OMP, nodeJS, bunJS ... "
    curl -s https://ohmyposh.dev/install.sh | bash -s | tee -a ~/.fis.log
    gum log --file ~/.fis.log --time DateTime --level info "[OK] Oh-my-posh installed!"
    curl -fsSL https://fnm.vercel.app/install | bash | tee -a ~/.fis.log
    curl -fsSL https://bun.sh/install | bash | tee -a ~/.fis.log
    source ~/.bashrc | tee -a ~/.fis.log
    fnm use --install-if-missing 22 | tee -a ~/.fis.log
    gum log --file ~/.fis.log --time DateTime --level info "[OK] NodeJS $(node -v) installed!"
    gum log --file ~/.fis.log --time DateTime --level info "[OK] BunJS v$(bun -v) installed!"
}

# Get config file for zsh, OMP
f-config() {
    # Asume code-server already installed
    gum log --file ~/.fis.log --time DateTime --level info "Getting config file for zsh, OMP ... "
    cp -r ~/.config/code-server ~/code-server-backup | tee -a ~/.fis.log
    rm -rf ~/.config | tee -a ~/.fis.log # Remove existing .config folder 
    git clone https://github.com/frsqredm/lxc-config-files.git ~/.config | tee -a ~/.fis.log
    cp -r ~/code-server-backup ~/.config/code-server | tee -a ~/.fis.log
    rm -rf ~/code-server-backup | tee -a ~/.fis.log
    rm ~/.zshrc | tee -a ~/.fis.log # Remove existing .zshrc file
    ln -s ~/.config/zsh/.zshrc ~/.zshrc | tee -a ~/.fis.log
    gum log --file ~/.fis.log --time DateTime --level info "[OK] Config files save at ~/.config folder!"
}

# Finish
f-finish() {
    gum log --file ~/.fis.log --time DateTime --level info "[OK] FIS Install Script finished!"
    gum log --time DateTime --level info "[OK] FIS Install Script finished!"
    printf "\nTODO: 
    1. Change default shell by chsh and exec zsh.
    2. Review and delete .fis.log file. \n" | tee -a ~/.fis.log
    rm ~/.fis.sh | tee -a ~/.fis.log
    gum log --time DateTime --level info  "Goodbye!"
}

# Cancell script
f-cancell () {
    gum log --file ~/.fis.log --time DateTime --level info "Cancelling script ..."
    rm ~/.fis.sh | tee -a ~/.fis.log
    gum log --file ~/.fis.log --time DateTime --level info "[CANCELL] FIS Install Script cancelled. See you later!"
    sleep 3
}

if [ "$ANS" == "yes" ]; then
    export -f f-packages f-git f-extra f-config f-finish
    gum log --time DateTime --level info "Installing essential packages ..."
    gum spin --spinner minidot --show-error --title="" -- bash -c f-packages
    gum log --time DateTime --level info "[OK] Essential packages installed!"
    sleep 2
    gum log --time DateTime --level info "Configuring git ..."
    gum spin --spinner minidot --show-error --title="" -- bash -c f-git
    gum log --time DateTime --level info "[OK] Done config git as frsqredm!"
    sleep 2
    gum log --time DateTime --level info "Installing OMP, nodeJS, bunJS ... "
    gum spin --spinner minidot --show-error --title="" -- bash -c f-extra
    gum log --time DateTime --level info "[OK] Oh-my-posh installed!"
    sleep 1
    gum log --time DateTime --level info "[OK] NodeJS $(node -v) installed!"
    sleep 1
    gum log --time DateTime --level info "[OK] BunJS v$(bun -v) installed!"
    sleep 2
    gum log --time DateTime --level info "Getting config file for zsh, OMP ... "
    gum spin --spinner minidot --show-error --title="G" -- bash -c f-config
    gum log --time DateTime --level info "[OK] Config files save at ~/.config folder!"
    sleep 2
    bash -c f-finish
    unset -f f-packages f-git f-extra f-config f-finish f-begin
else
    export -f f-cancell
    gum log --time DateTime --level info "Cancelling script ..."
    gum spin --spinner minidot --title="" -- bash -c f-cancell
    gum log --time DateTime --level info "[CANCELL] FIS Install Script cancelled. See you later!"
    unset -f f-cancell f-begin
fi