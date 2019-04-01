#!/bin/bash

function create_ruby_env {
    local rubyversion=$1
    local rubypatchlevel=$2
    local depsfile=$3

    # Install Ruby version
    if ! rvm list strings | grep "^ruby-$rubyversion\$" > /dev/null; then
        # https://stackoverflow.com/questions/37336573/unable-to-require-openssl-install-openssl-and-rebuild-ruby-preferred-or-use-n
        local openssldir=$(brew --prefix openssl)
        rvm install $rubyversion -l $rubypatchlevel --with-openssl-dir=$openssldir
    fi

    # Install/update gem dependencies
    rvm $rubyversion \do gem install --file $depsfile
}

basedir=$(dirname $0)
create_ruby_env 2.3.7 456 $basedir/ruby2.3.7-gem.deps.rb
