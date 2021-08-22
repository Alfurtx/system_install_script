#!/bin/sh

function check_is_laptop() {
    read -p "[fonsi] estas tratando de instalarlo en un portatil? [y/n]" yn
    case $yn in
        [yY]* ) export IS_LAPTOP=1;;
        [nN]* ) export IS_LAPTOP=0;;
        * ) echo "[fonsi] porfiplis, solo responde 'y' o 'n'";;
    esac
}

function check_is_vbox() {
    read -p "[fonsi] estas tratando de instalarlo en una maquina virtual? [y/n]" yn
    case $yn in
        [yY]* ) 
            export ISVIRT=1
            sudo pacman -S --needed virtualbox-guest-utils xf86-video-vmware xf86-video-fbdev
            VBoxClient-all
            ;;
        [nN]* ) 
            export ISVIRT=0
            ;;
        * ) 
            echo "[fonsi] porfiplis, solo responde 'y' o 'n'"
            ;;
    esac
}

function check_is_desktop() {
    read -p "[fonsi] estas tratando de instalarlo en un escritorio fisico? [y/n]" yn
    case $yn in
        [yY]* ) 
            export ISDESKTOP=1
            sudo pacman -S --needed nvidia
            nvidia-xconfig
            ;;
        [nN]* ) 
            export ISDESKTOP=0
            ;;
        * ) 
            echo "[fonsi] porfiplis, solo responde 'y' o 'n'"
            ;;
    esac
}

function make_makepkg_multithread() {
    sudo sh -c 'echo "MAKEFLAGS="-j$(nproc)"" >> /etc/makepkg.conf'
}

function install_wallpapers() {
    cd
    mkdir -p pictures/wallpapers 
    cd pictures/wallpaper 
    git clone https://github.com/Alfurtx/wallpapers.git
    cd
}

function install_laptop_stuff() {
    cd
    if [[ $IS_LAPTOP ]]; then
        sudo pacman -S --needed xf86-video-intel acpi cbatticon xf86-input-libinput xorg-xinput
    fi
}

function create_config_dir() {
    cd
    mkdir .config
    cd
}

function install_xorg() {
    sudo pacman -S --needed xorg xorg-xinit
}

function install_paru() {
    cd
    mkdir aux
    cd aux
    sudo pacman -S --needed base-devel
    git clone https://aur.archlinux.org/paru.git
    cd paru
    makepkg -si
    cd
}

function install_packages() {
    cd
    cd aux
    git clone https://gist.github.com/d2dab30b6d713d0bb657eac3dc072d83.git
    cd d2dab30b6d713d0bb657eac3dc072d83
    sed '/pacmanity/d' archvbox.pacmanity > packages
    paru -S --needed $(tr '\n' ' ' < packages)
    if [[ ! $ISVIRT ]]; then
        sudo pacman -Rs virtualbox-guest-utils xf86-video-vmware xf86-video-fbdev
    fi
    cd
}

function install_oh_my_zsh() {
    sh -c "$(wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"
    export ZSH_CUSTOM=/home/fonsi/.config/oh-my-zsh
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
    git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
    git clone https://github.com/lukechilds/zsh-nvm $ZSH_CUSTOM/plugins/zsh-nvm
}

function install_dotfiles() {
    cd
    cd .config
    
    yadm clone https://github.com/Alfurtx/dotfiles.git -w ~/.config

    if [[ $IS_LAPTOP ]]; then
        yadm config local.class laptop
    else
        yadm config local.class desktop
    fi

    cd
}

function set_system_zshenv() {
    sudo sh -c 'echo "export ZDOTDIR=~/.config/zsh" >> /etc/zsh/zshenv'
}

function cleanup() {
    cd
    rm -rf aux
    cd
}

# function ssh_key_gen() {
    # paru -S openssh xclip
    # echo "[fonsi] generating ssh key for this computer..."
    # ssh-keygen -t rsa -b 4096 -C "alfonso.alfurtx@gmail.com"
    # eval $(ssh-agent -s)
    # ssh-add ~/.ssh/id_rsa
    # echo "[fonsi] RECUERDA AÑADIR ESTA CLAVE A TU CUENTA DE GITHUB"
    # xclip -sel clip < ~/.ssh/id_rsa.pub
    # read -p "[fonsi] has añadido la clave a tu cuenta? [y/n]" yn
    # case $yn in
    #     [yY]* ) ;;
    #     [nN]* ) ;;
    # esac
# }

function main() {
    sudo pacman -Syu
    check_is_laptop
    check_is_vbox
    create_config_dir
    install_laptop_stuff
    install_xorg
    install_paru
    # ssh_key_gen
    install_packages
    set_system_zshenv
    install_dotfiles
    install_wallpapers
}

main
sudo reboot
