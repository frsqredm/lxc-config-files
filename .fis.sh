#!/bin/bash

fis_version="1.0.0"

# Install gum
echo "Installing gum ..."
apt -y install gpg
mkdir -p /etc/apt/keyrings
curl -fsSL https://repo.charm.sh/apt/gpg.key | gpg --dearmor -o /etc/apt/keyrings/charm.gpg
echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | tee /etc/apt/sources.list.d/charm.list
apt update && apt install gum
echo -e "\n-----> done\n"
sleep 1

# Introduction
gum style \
	    --border normal \
	    --align left --width 60 --margin "0 0" --padding "0 0" \
	    "FIS Install Script" \
        "1. Essential packages: zsh git tree unzip postgresql wget curl fzf zoxide" \
        "2. Git config" \
        "3. Install: OMP, nodeJS, bunJS" \
        "4. Get config file for zsh, OMP"

printf "\nContinue ? \n"
ANS=$(gum choose {yes,no})

# Install packages
f1() {
    apt -y install zsh git tree unzip postgresql wget curl fzf
    sleep 1
    curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
    printf "\n[ \u2714 ] done\n"
    sleep 1
}

# Config git
f2() {
    git config --global user.name frsqredm
    git config --global user.email fr.sqre.dm@gmail.com
    git config --global credential.helper "cache --timeout=604800"
    git config --global init.defaultBranch main
    sleep 2
    printf "\n[ \u2714 ] done config git as frsqredm\n"
    sleep 1
}

# Install OMP, nodeJS, bunJS
f3() {
    curl -s https://ohmyposh.dev/install.sh | bash -s
    printf "\n[ \u2714 ] oh-my-posh v$(oh-my-posh --version) installed\n"
    sleep 1
    curl -fsSL https://fnm.vercel.app/install | bash
    curl -fsSL https://bun.sh/install | bash
    source ~/.bashrc
    fnm use --install-if-missing 22
    printf "\n[ \u2714 ] nodeJS $(node -v) installed\n"
    sleep 1
    printf "\n[ \u2714 ] bunJS v$(bun -v) installed\n"
}

# Get config file for zsh, OMP
f4() {
    cp -r ~/.config/code-server ~/code-server-backup
    rm -rf ~/.config # Remove existing .config folder
    git clone https://github.com/frsqredm/lxc-config-files.git ~/.config
    cp -r ~/code-server-backup ~/.config/code-server
    rm -rf ~/code-server-backup
    rm ~/.zshrc # Remove existing .zshrc file
    ln -s ~/.config/zsh/.zshrc ~/.zshrc
    printf "\n[ \u2714 ] config files save at ~/.config\n"
    sleep 1
}

# Finish
f5() {
    printf "\n[ \u2714 ] FIS Install Script $fis_version finished !! \n"
    printf "\nTODO: chsh and exec zsh to change default shell to zsh"
    rm ~/.fis.sh
    sleep 1
}

# Cancell script
f6 () {
    printf "\nSee you later\n"
    rm ~/.fis.sh
    sleep 1
}

if [ "$ANS" == "yes" ]; then
    export -f f1 f2 f3 f4 f5 &&
    gum spin --spinner minidot --show-error --title="Install packages ... " -- bash -c f1 &&
    gum spin --spinner minidot --show-error --title="Config git ... " -- bash -c f2 &&
    gum spin --spinner minidot --show-error --title="Install OMP, nodeJS, bunJS ... " -- bash -c f3 &&
    gum spin --spinner minidot --show-error --title="Getting config files for zsh, OMP ... " -- bash -c f4 &&
    bash -c f5
else
    export -f f6 &&
    bash -c f6
fi