#!/usr/bin/env bash


set -e                      # exit all shells if script fails
set -u                      # exit script if uninitialized variable is used
set -o pipefail             # exit script if anything fails in pipe
shopt -s failglob           # fail on regex expansion fail

CALLING_DIRPATH="$(pwd)"                                            ; declare -r CALLING_DIRPATH
SCRIPT_FILENAME="$(basename "${0}")"                                ; declare -r SCRIPT_FILENAME
SCRIPT_DIRPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"  ; declare -r SCRIPT_DIRPATH


declare -r SCRIPT_FILEPATH="${SCRIPT_DIRPATH}/${SCRIPT_FILENAME}"


function main(){
    local -r user_password_symlink="${SCRIPT_DIRPATH}/_user_password"

    #eval $( op signin ) # this works since everything is done on localhost

    ansible-galaxy install -r requirements.yml

    local user_password=''

    if [[ ! -f "${user_password_symlink}" ]]; then
        local -r random_password_filepath="$(mktemp)"

        unlink "${user_password_symlink}" || true
        ln -s "${random_password_filepath}" "${user_password_symlink}"

        echo -n 'Password: '
        read -s user_password
        echo

        echo "${user_password}" > "${user_password_symlink}"
    fi

    unset user_password


    ansible-playbook main.yml \
        --inventory=./inventory \
        --extra-vars "ansible_sudo_pass='$( cat "${user_password_symlink}" )'"

    #ansible-playbook main.yml \
    #    --inventory=./inventory \
    #    --ask-become-pass
    
    exit 0
}
main
