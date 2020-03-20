prepare_xbindkeysrc() {
    local xbindkeysrc_file="$1"
    local symlink_has_created=0

    if [ ! -f .xbindkeysrc ]; then
        ln -s "$xbindkeysrc_file" .xbindkeysrc
        symlink_has_created=1
    fi
    run_xbindkeys
}

run_xbindkeys() {
    [ ! -f .xbindkeysrc ] && return

    if (pgrep -u "$USER" xbindkeys > /dev/null); then
        local physical_xbindkey_file="$(readlink .xbindkeysrc)"
        local age_of_file_in_sec="$(( $(date +%s) - $(stat -c %Y "$physical_xbindkey_file") ))"
        local pid_of_xbindkeys=$(pidof xbindkeys)
        local age_of_ps_in_sec="$(ps -p ${pid_of_xbindkeys} -o etimes:1 --no-headers)"

        if [ "$age_of_file_in_sec" -lt "$age_of_ps_in_sec" ]; then
            # Reload process if the age of process grater than the age of file
            echo "Reloading xbindkeys daemon because its config file .xbindkeysrc was updated."
            killall -HUP xbindkeys

            # Update a timestamp of the file not to reload xbindkeys with same config again
            local ps_start_date="$(ps -p ${pid_of_xbindkeys} -o lstart:1 --no-headers)"
            touch -d "$ps_start_date" "$physical_xbindkey_file"
        fi
    else
        xbindkeys --poll-rc
    fi
}

if (command -v xinput > /dev/null); then
    if (xinput --list | grep -E '.*Logitech MX Vertical Advanced Ergonomic Mouse\s+id=.*' > /dev/null); then
        prepare_xbindkeysrc
    else
        run_xbindkeys
    fi
fi
