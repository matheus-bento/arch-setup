#!/bin/bash

info() {
    printf "\033[0;32m%b\033[0m" "$1"
}


while true; do
    info "Choose the locale that will be used by the system (type \"l\" to list available locales)\n"

    read LOCALE

    case $LOCALE in
        l)
            cat /etc/locale.gen | sed "s/# //g" | awk '{print $1}' | less
            ;;
        *)
            [ ! -z "$(grep "$LOCALE" /etc/locale.gen)" ] && break;
            echo "Invalid locale"
            ;;
    esac
done

echo "$LOCALE" 

