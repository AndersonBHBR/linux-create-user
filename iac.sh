#!/bin/bash

set -euo pipefail

LOG_FILE="/var/log/iac_setup.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

validate_root() {
    if [ "$EUID" -ne 0 ]; then
        echo "Execute este script como root."
        exit 1
    fi
}

create_directories() {
    log "Criando diretórios..."
    mkdir -p /publico /adm /ven /sec
}

create_groups() {
    log "Criando grupos..."
    groupadd -f GRP_ADM
    groupadd -f GRP_VEN
    groupadd -f GRP_SEC
}

create_user_group() {
    local group=$1
    shift
    local users=("$@")

    for user in "${users[@]}"; do
        if id "$user" &>/dev/null; then
            log "Usuário $user já existe."
        else
            # -6 = SHA-512 (muito mais seguro que -crypt)
            useradd -m -s /bin/bash -p "$(openssl passwd -6 Senha123)" -G "$group" "$user"
            passwd -e "$user" >/dev/null 2>&1
            log "Usuário $user criado com sucesso."
        fi
    done
}

configure_permissions() {
    log "Configurando permissões..."

    chown root:GRP_ADM /adm
    chown root:GRP_VEN /ven
    chown root:GRP_SEC /sec

    chmod 770 /adm /ven /sec
    chmod 777 /publico
}

main() {
    validate_root

    log "Iniciando configuração da infraestrutura..."

    create_directories
    create_groups
    create_user_group GRP_ADM carlos maria joao
    create_user_group GRP_VEN debora sebastiana roberto
    create_user_group GRP_SEC josefina amanda rogerio
    configure_permissions

    log "Infraestrutura configurada com sucesso."
}

main