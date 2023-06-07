#!/usr/bin/bash

source linux/start.sh

stop::collabora()
{
    docker stop "$COLLABORA_CONTAINER_NAME" \
        >> "$LOGFILE_NAME" 2>&1

    if [ $? -eq 0 ]; then
        log_success "stoped collabora container"
    else
        log_error "couldnt stop collabora container"
    fi
}

stop::nextcloud()
{
    docker stop "$NEXTCLOUD_CONTAINER_NAME" \
        >> "$LOGFILE_NAME" 2>&1

    if [ $? -eq 0 ]; then
        log_success "stoped nextcloud container"
    else
        log_error "couldnt stop nextcloud container"
    fi
}

stop::main()
{
    stop::collabora
    stop::nextcloud
}

if [ "${BASH_SOURCE[0]}" == "$0" ]; then
    stop::main
fi
