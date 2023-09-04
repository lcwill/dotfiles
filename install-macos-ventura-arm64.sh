#!/bin/bash

# Exit script on command failure
set -e

DATE=$(date +%s)
BASE_DIR=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
BACKUP_DIR=$BASE_DIR/.backup
APPLICATIONS_DIR=/Applications

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
    ln -snf "$src_path" "$dst_link"
}

function brew_install {
    local package=$1
    shift
    local opts=$@
    if ! brew list $package > /dev/null 2>&1; then
        info Installing $package
        echo brew install $opts $package
    fi
    info $package installed
}

function brew_check_and_upgrade_version {
    local package=$1
    local version=$2
    if ! brew list --versions $package | grep -E " $version(_[0-9])?( .+)?\$" > /dev/null; then
        local stable_version=$(brew info --json $package | jq -r '.[0].versions.stable')
        if [[ "$stable_version" != "$version" ]]; then
            error $package $version not available as a stable version via HomeBrew
            exit 1
        fi
        if brew list $package > /dev/null 2>&1; then
            info Upgrading $package
            brew upgrade $package
        else
            info Installing $package
            brew install $package
        fi
    fi
    info $package $version installed
}


heading "Install Xcode tools and Homebrew"
if ! 'xcode-select' -p > /dev/null 2>&1; then
    'xcode-select' --install
fi
if ! command -v brew > /dev/null 2>&1; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
if ! command -v brew > /dev/null 2>&1; then
    export PATH=/opt/homebrew/bin:$PATH
fi

heading "Install Homebrew config"
backup_and_symlink $BASE_DIR/homebrew/bash_profile_arm64 $HOME/.bash_profile.d/10-brew

heading "Create common directories"
for d in .bin .profile.d .bash_profile.d .config Src; do
    info Creating $HOME/$d
    mkdir -p $HOME/$d
done

heading "Install common packages"
for p in bash-completion jq tree wget htop; do
    brew_install $p
done

heading "Install Bash config"
backup_and_symlink $BASE_DIR/bash/profile $HOME/.profile
backup_and_symlink $BASE_DIR/bash/bash_profile $HOME/.bash_profile

heading "Install oh-my-zsh"
if [[ ! -e $HOME/.oh-my-zsh ]]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

heading "Install zsh config"
backup_and_symlink $BASE_DIR/zsh/zshrc $HOME/.zshrc

heading "Install ssh config"
mkdir -p $HOME/.ssh
chmod 700 $HOME/.ssh
backup_and_symlink $BASE_DIR/ssh/config $HOME/.ssh/config
backup_and_symlink $BASE_DIR/ssh/bash_profile_macos $HOME/.bash_profile.d/00-ssh

heading "Install tig"
TIG_VERSION=2.5.8
brew_check_and_upgrade_version tig $TIG_VERSION

heading "Install Github CLI"
brew_install gh

heading "Install Git config"
backup_and_symlink $BASE_DIR/git/gitconfig $HOME/.gitconfig
backup_and_symlink $BASE_DIR/git/gitignore $HOME/.gitignore
for f in $BASE_DIR/git/bin/*; do
    backup_and_symlink $f $HOME/.bin/$(basename $f)
done

heading "Install AWS CLI"
brew_install awscli

heading "Install AWS config"
backup_and_symlink $BASE_DIR/aws $HOME/.aws

heading "Install Gcloud CLI"
if ! command -v gcloud > /dev/null 2>&1; then
    GCLOUD_ARCHIVE_URL="https://storage.googleapis.com/cloud-sdk-release/?prefix=google-cloud-cli"
    GCLOUD_LATEST_PACKAGE=$(curl -s "$GCLOUD_ARCHIVE_URL" | grep -o "[^>]\+darwin-arm[^<]\+" | tail -1)
    GCLOUD_DOWNLOAD_PATH="$(mktemp -d)/$GCLOUD_LATEST_PACKAGE"
    GCLOUD_RELEASE_URL="https://storage.googleapis.com/cloud-sdk-release/$GCLOUD_LATEST_PACKAGE"
    curl -sL -o $GCLOUD_DOWNLOAD_PATH $GCLOUD_RELEASE_URL
    tar xf $GCLOUD_DOWNLOAD_PATH -C $HOME/Src
fi

heading "Install Gcloud config"
backup_and_symlink $HOME/Src/google-cloud-sdk/path.zsh.inc $HOME/.bash_profile.d/20-gcloud
backup_and_symlink $HOME/Src/google-cloud-sdk/completion.zsh.inc $HOME/.bash_profile.d/21-gcloud-autocomplete

heading "Install Pyenv"
PYENV_VERSION=2.3.25
brew_check_and_upgrade_version pyenv $PYENV_VERSION
brew_install pyenv-virtualenv

heading "Install Neovim"
brew_install neovim

heading "Install Vim/Neovim config"
backup_and_symlink $BASE_DIR/vim/init.vim $HOME/.vimrc
backup_and_symlink $BASE_DIR/vim $HOME/.vim
backup_and_symlink $BASE_DIR/vim $HOME/.config/nvim
# Ensure plugin submodules have been initialized (none of the status lines should be prefixed with
# '-')
if git submodule status | grep "^-" > /dev/null; then
    git submodule update --init
fi
# # Compile C extension for Vim Command-T plugin
# COMMANDT_EXT_DIR=$BASE_DIR/vim/bundle/command-t/ruby/command-t/ext/command-t
# if [[ ! -f $COMMANDT_EXT_DIR/ext.o ]]; then
#     info Compiling Vim Command-T plugin
#     pushd $COMMANDT_EXT_DIR > /dev/null 2>&1
#     if [[ -f Makefile ]]; then
#         make clean
#     fi
#     rm -f Makefile
#     rvm 2.6.3 \do ruby extconf.rb
#     make
#     popd > /dev/null 2>&1
# fi
# # Install Vim plugin dependencies
# brew_install the_silver_searcher

heading "Install Yamllint config"
backup_and_symlink $BASE_DIR/yamllint $HOME/.config/yamllint

heading "Install Flake8 config"
backup_and_symlink $BASE_DIR/flake8/config $HOME/.config/flake8

heading "Install eslint config"
backup_and_symlink $BASE_DIR/eslint/eslintrc $HOME/.eslintrc

heading "Install htop config"
backup_and_symlink $BASE_DIR/htop $HOME/.config/htop

heading "Install Rectangle config"
mkdir -p "$HOME/Library/Application Support/Rectangle"
backup_and_symlink $BASE_DIR/rectangle/RectangleConfig.json "$HOME/Library/Application Support/Rectangle/RectangleConfig.json"

heading "Install Rectangle window manager"
brew_install rectangle --cask

heading "Install notunes"
brew_install notunes --cask

heading "Install Docker"
if ! docker version > /dev/null 2>&1; then
    DOCKER_DOWNLOAD_PATH="$(mktemp -d)/Docker.dmg"
    DOCKER_RELEASE_URL="https://desktop.docker.com/mac/main/arm64/Docker.dmg"
    DOCKER_MOUNT_PATH="$(mktemp -d)/Docker_Volume"

    info Downloading Docker OSX image
    curl -sL -o $DOCKER_DOWNLOAD_PATH $DOCKER_RELEASE_URL

    info Mounting image and installing Docker application
    hdiutil attach $DOCKER_DOWNLOAD_PATH -nobrowse -noautoopen -mountpoint $DOCKER_MOUNT_PATH
    cp -R $DOCKER_MOUNT_PATH/Docker.app $APPLICATIONS_DIR
    hdiutil detach $DOCKER_MOUNT_PATH

    info Starting Docker daemon
    open --hide --background -a Docker
fi
until command -v docker > /dev/null 2>&1; do
    echo "Waiting for Docker installation..."
    sleep 2
done
DOCKER_VERSION=$(echo $(docker system info | grep Server.Version | cut -d: -f2))
info "Docker $DOCKER_VERSION installed"

heading "Install Terraform"
brew tap hashicorp/tap
brew_install hashicorp/tap/terraform

heading "Install Terraform config"
backup_and_symlink $BASE_DIR/terraform/bash_profile_complete_arm64 $HOME/.bash_profile.d/30-terraform

heading "Install iTerm2"
if ! ls $APPLICATIONS_DIR/iTerm* > /dev/null 2>&1; then
    ITERM_DOWNLOAD_PATH="$(mktemp -d)/iTerm2.zip"
    ITERM_RELEASE_URL="https://iterm2.com/downloads/stable/latest"

    info Downloading and unzipping iTerm2 Latest
    curl -sL -o $ITERM_DOWNLOAD_PATH $ITERM_RELEASE_URL
    temp_dir=$(mktemp -d)
    unzip -d $temp_dir $ITERM_DOWNLOAD_PATH

    # Install into Applications dir and add security exception allowing the third-party app to be
    # opened: http://www.manpagez.com/man/8/spctl/
    mv $temp_dir/iTerm.app $APPLICATIONS_DIR
    # spctl --add $APPLICATIONS_DIR/iTerm.app
fi
info "iTerm2 installed"

heading "Install iTerm2 config"
backup_and_symlink $BASE_DIR/iterm2 $HOME/.config/iterm2
defaults import com.googlecode.iterm2 $HOME/.config/iterm2/com.googlecode.iterm2.plist

POSTGRES_VERSION=15
heading "Install Postgres $POSTGRES_VERSION"
brew_install postgresql@$POSTGRES_VERSION
if ! command -v psql > /dev/null 2>&1; then
    brew link postgresql@$POSTGRES_VERSION
fi
