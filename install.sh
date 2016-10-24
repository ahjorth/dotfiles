#!/usr/bin/env bash

# Dotfiles directory
dir=~/dotfiles

# Backup directory for old dotfiles
backupdir=~/dotfiles_old

# Update apt
sudo apt-get update

ask() {
    printf "\e[0;33m$1 \e[0m"
    read
}

symlink() {
    # Move existing dotfile to the backup directory
    # and replace it with a symlink.
    local src=$1 dst=$2

    if [ ! -h ~/.${dst}  ]; then
        if [ -f ~/.${dst} ]; then
            mv ~/.${dst} ${backupdir}/${src}
        fi

        echo "Creating symlink to $1: ~/.$2"
        ln -s ${dir}/${src} ~/.${dst}
    fi
}

install_git() {
    if [ -f /bin/zsh -o -f /usr/bin/zsh ]; then
        if [ ! -f ~/.gitconfig.local ]; then
            # Create a local gitconfig (~/.gitconfig.local)
            echo "Creating a local ~/.gitconfig.local"

            ask "What is your Git name?"
            git_name=$REPLY
            ask "What is your Git email?"
            git_email=$REPLY
            echo -e "[user]\n    name = $git_name\n    email = $git_email" > ~/.gitconfig.local
        fi
    else
        echo -e "\nGit is not installed. Installing ..."
        sudo apt-get install git
        install_git
    fi
}

install_terminator() {
    if [ -f /bin/zsh -o -f /usr/bin/zsh ]; then
        echo "Terminator already installed"
    else
        echo "Terminator not installed. Installing now ..."
        sudo apt-get install terminator
    fi
}

install_powerline-fonts() {
    cd ${dir}
    git clone https://github.com/powerline/fonts.git powerline-fonts
    ./powerline-fonts/install.sh
    sudo rm -rf powerline-fonts
}

install_oh-my-zsh() {
    cd ${dir}
    if [ -f /bin/zsh -o -f /usr/bin/zsh ]; then
        if [[ ! -d ${dir}/oh-my-zsh/ ]]; then
            echo "Cloning robbyrussell/oh-my-zsh"
            git clone http://github.com/robbyrussell/oh-my-zsh.git
        else
            echo "Oh-My-Zsh installed."
        fi

        ask "Do you want to make Zsh your default shell?"
        if [[ "$REPLY" =~ ^[Yy]$  ]]; then
            chsh -s $(which zsh)
        fi
    else
        echo -e "\nZsh is not installed. Installing ..."
        sudo apt-get install zsh
        install_oh-my-zsh
    fi
}

install_php() {
    if [ -f /bin/php7.0 -o -f /usr/bin/php7.0 ]; then
        echo "PHP installed. Installing mods ..."
        sudo apt-get install php7.0-cli php7.0-common php7.0-curl php7.0-json php7.0-mbstring php7.0-mcrypt php7.0-mysql php7.0-opcache php7.0-readline php7.0-xml php7.0-zip
    else
        sudo apt-get install php7.0-fpm
        install_php
    fi
}

install_mysql() {
    if [ -f /bin/mysql -o -f /usr/bin/mysql ]; then
        echo "Mysql installed"
    else
        sudo apt-get install mysql-server
        sudo mysql_secure_installation
        install_mysql
    fi

}

install_composer() {
    echo "Installing prerequisites ..."
    sudo apt-get install unzip curl

    cd ${dir}
    curl -sS https://getcomposer.org/installer -o composer-setup.php
    sudo php composer-setup.php --install-dir=/usr/bin --filename=composer

    rm composer-setup.php
}

install_valet() {
    composer global require cpriego/valet-ubuntu
    valet install
}

# Symlinks
symlink "zsh/zshrc" "zshrc"
symlink "oh-my-zsh" "oh-my-zsh"
symlink "gitconfig/gitconfig" "gitconfig"
symlink "terminator/config" "config/terminator/config"

source ~/.zshrc

echo "Dotfiles were installed!"