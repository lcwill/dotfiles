#!/bin/bash

# Exit script on command failure
set -e

DATE=$(date +%s)
BASE_DIR=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
BACKUP_DIR=$BASE_DIR/.backup

# Common bash variables and functions
source $BASE_DIR/bash_functions

function heading {
    echo -e "\n${underline}$@${normal}"
}

function backup_and_symlink {
    local src_path=$1
    local dst_link=$2
    if [[ -e $dst_link && ! -L $dst_link ]]; then
        local backup_path=${BACKUP_DIR}/$(basename $src_path)-$(basename $dst_link)-${DATE}
        warn "File or directory exists at $dst_link - backing up to $backup_path"
        mv $dst_link $backup_path
    fi
    info "Symlinking $dst_link -> $src_path"
    ln -snf $src_path $dst_link
}

function brew_install {
    local package=$1
    if ! brew list $package > /dev/null 2>&1; then
        info Installing $package
        brew install $package
    fi
    info $package installed
}

heading "Create common directories"
for d in .bin .profile.d .bash_profile.d .config; do
    info Creating $HOME/$d
    mkdir -p $HOME/$d
done

heading "Install common packages"
for p in git jq htop; do
    brew_install $p
done

heading "Install Bash config"
backup_and_symlink $BASE_DIR/bash/profile $HOME/.profile
backup_and_symlink $BASE_DIR/bash/bash_profile $HOME/.bash_profile
backup_and_symlink $BASE_DIR/bash/virtualenvify.sh $HOME/.bin/virtualenvify

heading "Install ssh config"
backup_and_symlink $BASE_DIR/ssh/config $HOME/.ssh/config
backup_and_symlink $BASE_DIR/ssh/bash_profile_macos $HOME/.bash_profile.d/00-ssh

heading "Install Git config"
backup_and_symlink $BASE_DIR/git/gitconfig $HOME/.gitconfig
backup_and_symlink $BASE_DIR/git/gitignore $HOME/.gitignore
for f in $BASE_DIR/git/bin/*; do
    backup_and_symlink $f /usr/local/bin/$(basename $f)
done

heading "Install Neovim"
NVIM_VERSION=0.3.4
if ! nvim --version 2>/dev/null | grep "v$NVIM_VERSION" > /dev/null; then
    NVIM_DOWNLOAD_PATH="$(mktemp -d)/nvim-macos-${NVIM_VERSION}.tar.gz"
    NVIM_INSTALL_PATH="$HOME/nvim-${NVIM_VERSION}-osx64"
    NVIM_INSTALL_SYMLINK="$HOME/nvim-osx64"
    NVIM_RELEASE_URL="https://github.com/neovim/neovim/releases/download/v${NVIM_VERSION}/nvim-macos.tar.gz"

    info Downloading and unzipping NVIM v$NVIM_VERSION to $NVIM_INSTALL_PATH
    curl -sL -o $NVIM_DOWNLOAD_PATH $NVIM_RELEASE_URL
    temp_dir=$(mktemp -d)
    tar -C $temp_dir -xf $NVIM_DOWNLOAD_PATH
    rm -rf $NVIM_INSTALL_PATH
    mv $temp_dir/nvim-osx64 $NVIM_INSTALL_PATH
    backup_and_symlink $NVIM_INSTALL_PATH $NVIM_INSTALL_SYMLINK
fi
info "NVIM v$NVIM_VERSION installed"

heading "Install Vim/Neovim config"
backup_and_symlink $BASE_DIR/vim/init.vim $HOME/.vimrc
backup_and_symlink $BASE_DIR/vim $HOME/.vim
backup_and_symlink $BASE_DIR/vim $HOME/.config/nvim

heading "Install AWS config"
backup_and_symlink $BASE_DIR/aws $HOME/.aws

heading "Install RVM config"
backup_and_symlink $BASE_DIR/rvm/profile $HOME/.profile.d/10-rvm

heading "Install PyEnv config"
backup_and_symlink $BASE_DIR/pyenv/profile $HOME/.profile.d/20-pyenv

heading "Install Slate config"
backup_and_symlink $BASE_DIR/slate/slate.js $HOME/.slate.js

heading "Install Tmux config"
backup_and_symlink $BASE_DIR/tmux/tmux.conf $HOME/.tmux.conf
mkdir -p $HOME/.tmux
backup_and_symlink $BASE_DIR/tmux/plugins $HOME/.tmux/plugins

heading "Install Yamllint config"
backup_and_symlink $BASE_DIR/yamllint $HOME/.config/yamllint

heading "Install Flake8 config"
backup_and_symlink $BASE_DIR/flake8/config $HOME/.config/flake8

heading "Install eslint config"
backup_and_symlink $BASE_DIR/eslint/eslintrc $HOME/.eslintrc

heading "Install htop config"
backup_and_symlink $BASE_DIR/htop $HOME/.config/htop
