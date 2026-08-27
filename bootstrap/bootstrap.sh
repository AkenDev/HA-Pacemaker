#!/usr/bin/env bash

set -Eeuo pipefail

################################################################################
# Secure HA Cluster Lab
#
# Bootstrap Phase
#
# Creates the automation account used by Ansible.
################################################################################

readonly ANSIBLE_USER="ansible"
readonly ANSIBLE_HOME="/home/${ANSIBLE_USER}"
readonly SSH_DIR="${ANSIBLE_HOME}/.ssh"
readonly AUTHORIZED_KEYS="${SSH_DIR}/authorized_keys"
readonly LAB_PUBLIC_KEY="/tmp/lab_ed25519.pub"
readonly TEMP_BOOTSTRAP="/tmp/bootstrap.sh"
readonly TEMP_PUBLIC_KEY="/tmp/lab_ed25519.pub"
readonly SUDOERS_FILE="/etc/sudoers.d/${ANSIBLE_USER}"
readonly SUDO_GROUP="wheel"

log() {
    local level="$1"
    shift

    printf '[%s] %s\n' "${level}" "$*"
}

require_root() {
    if [[ "${EUID}" -ne 0 ]]; then
        log ERROR "This script must be executed as root."
        exit 1
    fi
}

create_ansible_user() {
    if id "${ANSIBLE_USER}" &>/dev/null; then
        log INFO "User '${ANSIBLE_USER}' already exists."
        return
    fi

    log INFO "Creating user '${ANSIBLE_USER}'."

    useradd \
        --create-home \
        --shell /bin/bash \
        "${ANSIBLE_USER}"

    log INFO "User '${ANSIBLE_USER}' created successfully."
}

create_ssh_directory() {

    if ! id "${ANSIBLE_USER}" &>/dev/null; then
        log ERROR "User '${ANSIBLE_USER}' does not exist."
        return 1
    fi

    log INFO "Ensuring SSH directory exists."

    mkdir -p "${SSH_DIR}"

    chown "${ANSIBLE_USER}:${ANSIBLE_USER}" "${SSH_DIR}"

    chmod 700 "${SSH_DIR}"

    log INFO "SSH directory is ready."

}

install_authorized_key() {
    if [[ ! -f "${LAB_PUBLIC_KEY}" ]]; then
        log ERROR "Public key not found: ${LAB_PUBLIC_KEY}"
        return 1
    fi
    
    if [[ ! -d "${SSH_DIR}" ]]; then
        log ERROR "The SSH directory doesn't exist: ${SSH_DIR}"
        return 1
    fi

    log INFO "Installing authorized SSH key."

    install \
        -o "${ANSIBLE_USER}" \
        -g "${ANSIBLE_USER}" \
        -m 600 \
        "${LAB_PUBLIC_KEY}" \
        "${AUTHORIZED_KEYS}"

    log INFO "Authorized SSH key installed."

}


configure_sudo() {

    local sudoers_tmp

    if ! getent group "${SUDO_GROUP}" >/dev/null; then
        log ERROR "Group '${SUDO_GROUP}' does not exist."
        return 1
    fi

    if ! id "${ANSIBLE_USER}" &>/dev/null; then
        log ERROR "User '${ANSIBLE_USER}' does not exist."
        return 1
    fi

    if ! id -nG "${ANSIBLE_USER}" | grep -qw "${SUDO_GROUP}"; then
        log INFO "Adding '${ANSIBLE_USER}' to group '${SUDO_GROUP}'."

        usermod -aG "${SUDO_GROUP}" "${ANSIBLE_USER}"

        if ! id -nG "${ANSIBLE_USER}" | grep -qw "${SUDO_GROUP}"; then
            log ERROR "Failed to add '${ANSIBLE_USER}' to '${SUDO_GROUP}'."
            return 1
        fi
    else
        log INFO "User '${ANSIBLE_USER}' already belongs to '${SUDO_GROUP}'."
    fi

    

    sudoers_tmp="$(mktemp)"

    cat <<EOF > "${sudoers_tmp}"
${ANSIBLE_USER} ALL=(ALL) NOPASSWD: ALL
EOF

    if ! visudo -cf "${sudoers_tmp}" >/dev/null; then
        log ERROR "Sudoers validation failed."

        rm -f "${sudoers_tmp}"

        return 1
    fi

    install \
        -o root \
        -g root \
        -m 440 \
        "${sudoers_tmp}" \
        "${SUDOERS_FILE}"

    rm -f "${sudoers_tmp}"

    log INFO "Passwordless sudo configured."

}

cleanup() {

    log INFO "Removing temporary provisioning files."

    rm -f "$TEMP_BOOTSTRAP"
    rm -f "$TEMP_PUBLIC_KEY"
}

main() {

    require_root

    log INFO "Bootstrap started."

    create_ansible_user

    create_ssh_directory

    install_authorized_key

    configure_sudo

    log INFO "Bootstrap completed."
}

trap cleanup EXIT

main "$@"