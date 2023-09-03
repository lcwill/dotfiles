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

function brew_check_and_upgrade_version {
    local package=$1
    local version=$2
    if ! brew list --versions -l $package | grep -E " $version(_[0-9])?( .+)?\$" > /dev/null; then
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

function create_ruby_env {
    local rubyversion=$1
    local rubypatchlevel=$2
    local depsfile=$3

    # Install Ruby version
    if ! rvm list strings | grep "^ruby-$rubyversion\$" > /dev/null; then
        # https://stackoverflow.com/questions/37336573/unable-to-require-openssl-install-openssl-and-rebuild-ruby-preferred-or-use-n
        local openssldir=$(brew --prefix openssl)
        info Installing Ruby $rubyversion
        rvm install $rubyversion -l $rubypatchlevel --with-openssl-dir=$openssldir
    fi

    # Install/update gem dependencies
    info Updating Ruby dependencies
    rvm $rubyversion \do gem install --file $depsfile
}

function install_and_create_virtualenv {
    local pythonversion=$1
    local virtualenvname=$2
    local requirementsfile=$3

    # Install Python version
    if ! pyenv versions --bare | grep "^$pythonversion\$" > /dev/null; then
        # https://github.com/pyenv/pyenv/issues/1219
        export LDFLAGS="-L/usr/local/opt/zlib/lib -L/usr/local/opt/sqlite/lib"
        export CPPFLAGS="-I/usr/local/opt/zlib/include -I/usr/local/opt/sqlite/include"
        info Installing Python $pythonversion
        pyenv install $pythonversion
    fi

    # Create virtualenv
    info "Updating Python dependencies for virtualenv $virtualenvname"
    if ! pyenv virtualenvs --bare | grep "^$virtualenvname\$" > /dev/null; then
        pyenv virtualenv $pythonversion $virtualenvname
    fi

    # Install/update virtualenv dependencies
    eval "$(pyenv init -)"
    eval "$(pyenv virtualenv-init -)"
    pyenv activate $virtualenvname > /dev/null 2>&1
    pip install --upgrade pip setuptools > /dev/null 2>&1
    pip install -r $requirementsfile
    pyenv deactivate
}

heading "Install Xcode tools and Homebrew"
if ! 'xcode-select' -p > /dev/null 2>&1; then
    'xcode-select' --install
fi
if ! command -v brew > /dev/null 2>&1; then
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

heading "Create common directories"
for d in .bin .profile.d .bash_profile.d .config; do
    info Creating $HOME/$d
    mkdir -p $HOME/$d
done

heading "Install common packages"
for p in bash-completion git jq tree wget htop sqlite zlib; do
    brew_install $p
done

heading "Install Bash config"
backup_and_symlink $BASE_DIR/bash/profile $HOME/.profile
backup_and_symlink $BASE_DIR/bash/bash_profile $HOME/.bash_profile
backup_and_symlink $BASE_DIR/bash/virtualenvify.sh $HOME/.bin/virtualenvify

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
TIG_VERSION=2.5.0
brew_check_and_upgrade_version tig $TIG_VERSION

heading "Install Git config"
backup_and_symlink $BASE_DIR/git/gitconfig $HOME/.gitconfig
backup_and_symlink $BASE_DIR/git/gitignore $HOME/.gitignore
for f in $BASE_DIR/git/bin/*; do
    backup_and_symlink $f /usr/local/bin/$(basename $f)
done

heading "Install AWS CLIv2"
if ! command -v aws > /dev/null 2>&1; then
    AWS_CLI_DOWNLOAD_DIR="$(mktemp -d)"
    AWS_CLI_DOWNLOAD_PATH="$AWS_CLI_DOWNLOAD_DIR/AWSCLIV2.pkg"
    AWS_CLI_INSTALL_PATH=$HOME
    curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o $AWS_CLI_DOWNLOAD_PATH
    cat $BASE_DIR/aws/installer_choices.template.xml | \
        sed "s#AWS_CLI_INSTALL_PATH#$AWS_CLI_INSTALL_PATH#" > $AWS_CLI_DOWNLOAD_DIR/choices.xml
    installer -pkg $AWS_CLI_DOWNLOAD_PATH -target CurrentUserHomeDirectory \
        -applyChoiceChangesXML $AWS_CLI_DOWNLOAD_DIR/choices.xml
    ln -snf $AWS_CLI_INSTALL_PATH/aws-cli/aws /usr/local/bin/aws
    ln -snf $AWS_CLI_INSTALL_PATH/aws-cli/aws_completer /usr/local/bin/aws_completer
fi

heading "Install AWS config"
backup_and_symlink $BASE_DIR/aws $HOME/.aws

heading "Install RVM"
if ! rvm --version > /dev/null 2>&1; then
    RVM_RELEASE_URL="https://get.rvm.io"

    # https://rvm.io/rvm/install
    info Installing RVM from $RVM_RELEASE_URL
    export rvm_ignore_dotfiles=yes
    curl -sSL $RVM_RELEASE_URL | bash -s stable
fi

heading "Install RVM config"
backup_and_symlink $BASE_DIR/rvm/profile $HOME/.profile.d/10-rvm
if ! command -v rvm > /dev/null 2>&1; then
    # Ensure that the rvm command is on the PATH for the remainder of this script, ignoring warnings
    # about a path mismatch
    export PATH="$PATH:$HOME/.rvm/bin"
    export rvm_silence_path_mismatch_check_flag=1
fi

heading "Install Ruby versions"
# Install Ruby 2.6.3 with required Neovim dependencies and set as default
create_ruby_env 2.6.3 62 $BASE_DIR/vim/rubyenv/ruby2.6.3-gem.deps.rb
rvm alias create default 2.6.3

heading "Install Pyenv"
PYENV_VERSION=2.3.14
brew_check_and_upgrade_version pyenv $PYENV_VERSION
brew_install pyenv-virtualenv

heading "Install Python versions"
install_and_create_virtualenv 3.5.5 nvim-python3 \
    $BASE_DIR/vim/pythonenv/python3.5-requirements.lock
install_and_create_virtualenv 3.7.2 nvim-python37 \
    $BASE_DIR/vim/pythonenv/python3.7-requirements.lock

heading "Install Neovim"
NVIM_VERSION=0.4.3
NVIM_INSTALL_PATH="$HOME/nvim-${NVIM_VERSION}-osx64"
if ! nvim --version 2>/dev/null | grep "v$NVIM_VERSION" > /dev/null; then
    NVIM_DOWNLOAD_PATH="$(mktemp -d)/nvim-macos-${NVIM_VERSION}.tar.gz"
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
backup_and_symlink $NVIM_INSTALL_PATH/bin/nvim /usr/local/bin/nvim
info "NVIM v$NVIM_VERSION installed"

heading "Install Vim/Neovim config"
backup_and_symlink $BASE_DIR/vim/init.vim $HOME/.vimrc
backup_and_symlink $BASE_DIR/vim $HOME/.vim
backup_and_symlink $BASE_DIR/vim $HOME/.config/nvim
# Ensure plugin submodules have been initialized (none of the status lines should be prefixed with
# '-')
if git submodule status | grep "^-" > /dev/null; then
    git submodule update --init
fi
# Compile C extension for Vim Command-T plugin
COMMANDT_EXT_DIR=$BASE_DIR/vim/bundle/command-t/ruby/command-t/ext/command-t
if [[ ! -f $COMMANDT_EXT_DIR/ext.o ]]; then
    info Compiling Vim Command-T plugin
    pushd $COMMANDT_EXT_DIR > /dev/null 2>&1
    if [[ -f Makefile ]]; then
        make clean
    fi
    rm -f Makefile
    rvm 2.6.3 \do ruby extconf.rb
    make
    popd > /dev/null 2>&1
fi
# Install Vim plugin dependencies
brew_install the_silver_searcher

heading "Install Tmux"
TMUX_VERSION=3.0a
brew_check_and_upgrade_version tmux $TMUX_VERSION

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

heading "Install Slate config"
backup_and_symlink $BASE_DIR/slate/slate.js $HOME/.slate.js

heading "Install Slate"
if ! ls $APPLICATIONS_DIR/Slate.app > /dev/null 2>&1; then
    SLATE_DOWNLOAD_PATH="$(mktemp -d)/Slate.dmg"
    SLATE_RELEASE_URL="http://slate.ninjamonkeysoftware.com/Slate.dmg"
    SLATE_MOUNT_PATH="$(mktemp -d)/Slate_Volume"

    info Downloading Slate OSX Image
    curl -sL -o $SLATE_DOWNLOAD_PATH $SLATE_RELEASE_URL

    info Mounting image and installing Slate application
    hdiutil attach $SLATE_DOWNLOAD_PATH -nobrowse -noautoopen -mountpoint $SLATE_MOUNT_PATH
    cp -R $SLATE_MOUNT_PATH/Slate.app $APPLICATIONS_DIR
    hdiutil detach $SLATE_MOUNT_PATH

    info Starting Slate
    open --hide --background -a Slate
fi
info "Slate installed"

heading "Install Docker"
if ! docker version > /dev/null 2>&1; then
    DOCKER_DOWNLOAD_PATH="$(mktemp -d)/Docker.dmg"
    DOCKER_RELEASE_URL="https://download.docker.com/mac/stable/Docker.dmg"
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
TERRAFORM_VERSION=0.12.21
TERRAFORM_INSTALL_PATH="$HOME/terraform-${TERRAFORM_VERSION}-amd64"
if ! terraform --version 2>/dev/null | grep "v$TERRAFORM_VERSION" > /dev/null; then
    TERRAFORM_DOWNLOAD_PATH="$(mktemp -d)/terraform-${TERRAFORM_VERSION}-amd64.tar.gz"
    TERRAFORM_INSTALL_SYMLINK="$HOME/terraform-amd64"
    TERRAFORM_RELEASE_URL="https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_darwin_amd64.zip"

    info Downloading and unzipping Terraform v$TERRAFORM_VERSION to $TERRAFORM_INSTALL_PATH
    curl -sL -o $TERRAFORM_DOWNLOAD_PATH $TERRAFORM_RELEASE_URL
    temp_dir=$(mktemp -d)
    unzip -d $temp_dir $TERRAFORM_DOWNLOAD_PATH
    rm -rf $TERRAFORM_INSTALL_PATH
    mkdir $TERRAFORM_INSTALL_PATH
    mv $temp_dir/terraform $TERRAFORM_INSTALL_PATH
    backup_and_symlink $TERRAFORM_INSTALL_PATH $TERRAFORM_INSTALL_SYMLINK
fi
backup_and_symlink $TERRAFORM_INSTALL_PATH/terraform /usr/local/bin/terraform
info "Terraform v$TERRAFORM_VERSION installed"

heading "Install iTerm2"
if ! ls $APPLICATIONS_DIR/iTerm* > /dev/null 2>&1; then
    ITERM_LATEST_TAG=$(git ls-remote --sort=-version:refname --tags git@github.com:gnachman/iTerm2 | grep -o 'v\d\+\.\d\+\.\d\+$' | head -1)
    ITERM_URL_VERSION=$(echo $ITERM_LATEST_TAG | sed 's/^v//' | sed 's/\./_/g')
    ITERM_DOWNLOAD_PATH="$(mktemp -d)/iTerm2-${ITERM_LATEST_TAG}.zip"
    ITERM_RELEASE_URL="https://iterm2.com/downloads/stable/iTerm2-${ITERM_URL_VERSION}.zip"

    info Downloading and unzipping iTerm2 $ITERM_LATEST_TAG
    curl -sL -o $ITERM_DOWNLOAD_PATH $ITERM_RELEASE_URL
    temp_dir=$(mktemp -d)
    unzip -d $temp_dir $ITERM_DOWNLOAD_PATH

    # Install into Applications dir and add security exception allowing the third-party app to be
    # opened: http://www.manpagez.com/man/8/spctl/
    mv $temp_dir/iTerm.app $APPLICATIONS_DIR
    spctl --add $APPLICATIONS_DIR/iTerm.app
fi
info "iTerm2 installed"

heading "Install iTerm2 config"
backup_and_symlink $BASE_DIR/iterm2 $HOME/.config/iterm2
defaults import com.googlecode.iterm2 $HOME/.config/iterm2/com.googlecode.iterm2.plist
