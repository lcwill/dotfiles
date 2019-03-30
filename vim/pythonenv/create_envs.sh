#!/bin/bash

function install_and_create_virtualenv {
    local pythonversion=$1
    local virtualenvname=$2
    local requirementsfile=$3

    # Install Python version
    if ! pyenv versions --bare | grep "^$pythonversion\$" > /dev/null; then
        # https://github.com/pyenv/pyenv/issues/1219
        export LDFLAGS="-L/usr/local/opt/zlib/lib -L/usr/local/opt/sqlite/lib"
        export CPPFLAGS="-I/usr/local/opt/zlib/include -I/usr/local/opt/sqlite/include"
        pyenv install $pythonversion
    fi

    # Create virtualenv
    if ! pyenv virtualenvs --bare | grep "^$virtualenvname\$" > /dev/null; then
        pyenv virtualenv $pythonversion $virtualenvname
    fi

    # Install/update virtualenv dependencies
    eval "$(pyenv init -)"
    eval "$(pyenv virtualenv-init -)"
    pyenv activate $virtualenvname
    pip install --upgrade pip setuptools
    pip install -r $requirementsfile
    pyenv deactivate
}

basedir=$(dirname $0)
install_and_create_virtualenv 2.7.10 nvim-python $basedir/python2.7-requirements.lock
install_and_create_virtualenv 3.5.5 nvim-python3 $basedir/python3.5-requirements.lock
install_and_create_virtualenv 3.7.2 nvim-python37 $basedir/python3.7-requirements.lock
