#!/usr/bin/env bash

set -e                      # exit all shells if script fails
set -u                      # exit script if uninitialized variable is used
set -o pipefail             # exit script if anything fails in pipe
shopt -s failglob           # fail on regex expansion fail

function main(){
    ansible-galaxy install -r requirements.yml

    ansible-playbook main.yml \
        --inventory=./inventory \
        --ask-become-pass
    
    exit 0
}
main
