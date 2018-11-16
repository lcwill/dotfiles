#!/bin/bash

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

heading Install Bash config
mkdir -p $HOME/.bin
mkdir -p $HOME/.profile.d
mkdir -p $HOME/.bash_profile.d
backup_and_symlink $BASE_DIR/bash/profile $HOME/.profile
backup_and_symlink $BASE_DIR/bash/bash_profile $HOME/.bash_profile
backup_and_symlink $BASE_DIR/bash/virtualenvify.sh $HOME/.bin/virtualenvify

heading Install ssh config
backup_and_symlink $BASE_DIR/ssh/config $HOME/.ssh/config
backup_and_symlink $BASE_DIR/ssh/bash_profile_macos $HOME/.bash_profile.d/00-ssh

heading Install RVM config
backup_and_symlink $BASE_DIR/rvm/profile $HOME/.profile.d/10-rvm

heading Install PyEnv config
backup_and_symlink $BASE_DIR/pyenv/profile $HOME/.profile.d/20-pyenv
