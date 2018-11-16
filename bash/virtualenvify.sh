#!/bin/bash

# Inspired by: https://gist.github.com/datagrok/2199506

function _activate() {
    export VIRTUAL_ENV="$VIRTUALENV_PATH"
    export PATH="$VIRTUAL_ENV/bin:$PATH"
    unset PYTHON_HOME
}

function _deactivate() {
    if [[ -n "$VIRTUAL_ENV" ]]; then
        local pathfirst="$(echo $PATH | cut -d: -f1)"
        local pathrest="$(echo $PATH | cut -d: -f2-)"
        if [[ "$VIRTUAL_ENV/bin" == "$pathfirst" ]]; then
            export PATH=$pathrest
        fi
    fi
    unset VIRTUAL_ENV
}


if [[ -n "$VIRTUAL_ENV" ]]; then
    if [[ "$VIRTUAL_ENV" != "$VIRTUALENV_PATH" ]]; then
        _deactivate
        _activate
    fi
else
    _activate
fi

exec $@
