#!/usr/bin/bash

COLLABORA_EXTENSION=soblex_hsb_w6_3.06.00_16.02.2023_sc_th_hy.oxt

COLLABORA_CONTAINER_NAME=collabora_project_collabora
NEXTCLOUD_CONTAINER_NAME=collabora_project_nextcloud
LOGFILE_NAME=/dev/null

log_success()
{
    local LOG_GREEN="\033[0;32m"
    local LOG_RESET="\033[0m"
    echo -e "$LOG_GREEN success: $1 $LOG_RESET"
}

log_error()
{
    local LOG_RED="\033[0;31m"
    local LOG_RESET="\033[0m"
    echo -e "$LOG_RED error: $1 $LOG_RESET"
}

start::nextcloud()
{
    docker run --rm -d -p 80:80 --name $NEXTCLOUD_CONTAINER_NAME nextcloud \
        >> $LOGFILE_NAME 2>&1
    # --rm (remove container from history)
    # -d (detach from tty)
    # -p (port forward)

    if [ $? -eq 0 ]; then
        log_success "nextcloud container running"
    else
        log_error "couldnt run nextcloud container"
        exit
    fi
}

start::collabora()
{
    wget -N https://soblex.de/spellchecker_extension_update/$COLLABORA_EXTENSION \
        >> $LOGFILE_NAME 2>&1
    # -N (overwrite)

    if [ -f $COLLABORA_EXTENSION ]; then
        log_success "downloaded extension"
    else
        log_error "couldnt download extension"
        exit
    fi

    unzip -o -d dict-so $COLLABORA_EXTENSION >> $LOGFILE_NAME 2>&1
    # -o (overwrite)
    # -d (destination directory)

    if [ -d dict-so ]; then
        log_success "extracted extension"
    else
        log_error "couldnt extract extension"
        exit
    fi

    docker build -f dockerfile.collabora -t bnjmn/collabora . \
        >> $LOGFILE_NAME 2>&1
    # -f (use specific file)
    # -t (give image a name)

    if [ $? -eq 0 ]; then
        log_success "created collabora docker image"
    else
        log_error "couldnt create collabora docker image"
        exit
    fi
    
    docker run --rm -d -p 9980:9980 -e "extra_params=--o:ssl.enable=false" \
        --name $COLLABORA_CONTAINER_NAME bnjmn/collabora >> $LOGFILE_NAME 2>&1
    # --rm (remove container from history)
    # -d (detach from tty)
    # -p (port forward)
    # -e (run container with env variable)
    # --name (give running container a name)

    if [ $? -eq 0 ]; then
        log_success "collabora container running"
    else
        log_error "couldnt run collabora container"
        exit
    fi

    rm -vrf dict-so $COLLABORA_EXTENSION >> $LOGFILE_NAME 2>&1
}

start::main()
{
    start::collabora
    start::nextcloud
}

if [ "${BASH_SOURCE[0]}" == "$0" ]; then
    start::main
fi
