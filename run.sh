#!/usr/bin/env bash


set -e                      # exit all shells if script fails
set -u                      # exit script if uninitialized variable is used
set -o pipefail             # exit script if anything fails in pipe
shopt -s failglob           # fail on regex expansion fail

CALLING_DIRPATH="$(pwd)"                                            ; declare -r CALLING_DIRPATH
SCRIPT_FILENAME="$(basename "${0}")"                                ; declare -r SCRIPT_FILENAME
SCRIPT_DIRPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"  ; declare -r SCRIPT_DIRPATH


declare -r SCRIPT_FILEPATH="${SCRIPT_DIRPATH}/${SCRIPT_FILENAME}"


function secret_handler(){
    local -r symlink_path="${1}"
    local -r prompt="${2}"

    if [[ ! -f "${symlink_path}" ]]; then
        local -r secret_random_filepath="$(mktemp)"
        local user_input=''

        unlink "${symlink_path}" || true
        ln -s "${secret_random_filepath}" "${symlink_path}"

        echo -n "${prompt}:"
        read -s user_input
        echo

        echo "${user_input}" > "${symlink_path}"

        unset user_input
    fi
}

function main(){
    #eval $( op signin ) # this works since everything is done on localhost

    local -r sudo_password_symlink="${SCRIPT_DIRPATH}/_sudo_password"
    local -r op_username_symlink="${SCRIPT_DIRPATH}/_op_username"
    local -r op_secret_key_symlink="${SCRIPT_DIRPATH}/_op_password"
    local -r op_subdomain_symlink="${SCRIPT_DIRPATH}/_op_subdomain"
    local -r op_password_symlink="${SCRIPT_DIRPATH}/_op_password"

    ansible-galaxy install -r requirements.yml


    secret_handler "${sudo_password_symlink}" 'sudo password'
#    secret_handler "${op_username_symlink}" 'op username'
#    secret_handler "${op_secret_key_symlink}" 'op secret key'
#    secret_handler "${op_subdomain_symlink}" 'op subdomain'
#    secret_handler "${op_password_symlink}" 'op password'

    local -r sudo_password="$( cat "${sudo_password_symlink}" )"
#    local -r op_username="$( cat "${op_username}" )"
#    local -r op_secret_key="$( cat "${op_secret_key}" )"
#    local -r op_subdomain="$( cat "${op_subdomain}" )"
#    local -r op_password="$( cat "${op_password}" )"



#    yes "${op_password}" | \
#        op signin \
#        "${op_subdomain}" \
#        "${op_username}" \
#        "${op_secret_key}"



    ansible-playbook main.yml \
        --inventory=./inventory \
        --extra-vars "ansible_sudo_pass='$( cat "${sudo_password_symlink}" )'"

    #ansible-playbook main.yml \
    #    --inventory=./inventory \
    #    --ask-become-pass
    
    exit 0
}
main
