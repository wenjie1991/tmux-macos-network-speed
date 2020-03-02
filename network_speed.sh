#!/bin/bash -

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$CURRENT_DIR/helpers.sh"

default_download_color="#[fg=green]"
default_upload_color="#[fg=yellow]"

get_speed()
{
    # Consts
    local THOUSAND=1024
    local MILLION=1048576

    local new=$1
    local current=$2
    local vel=0

    local interval=$(get_tmux_option 'status-interval' 3)

    if [ ! "$current" -eq "0" ]; then
      vel=$(echo "$(( $new - $current )) $interval" | awk '{print ($1 / $2)}')
    fi

    local vel_kb=$(echo "$vel" $THOUSAND | awk '{print ($1 / $2)}')
    local vel_mb=$(echo "$vel" $MILLION | awk '{print ($1 / $2)}')

    result=$(printf "%05.2f > 99.99\n" $vel_kb | bc -l)
    if [[ $result == 1 ]]; then
        printf "%05.2f MB/s" $vel_mb
    else
        printf "%05.2f KB/s" $vel_kb
    fi
}

network_interface=$(get_tmux_option "@macos_network_speed_interface" "en0")
c_tx=$(get_tmux_option "@macos_network_speed_tx" 0)
c_rx=$(get_tmux_option "@macos_network_speed_rx" 0)

speed_output=$(macos-network-speed en8)
n_rx=$(echo "$speed_output" | grep RX | cut -d: -f2 | awk '{print $1}')
n_tx=$(echo "$speed_output" | grep TX | cut -d: -f2 | awk '{print $1}')
tmux set-option -gq "@macos_network_speed_tx" $n_tx
tmux set-option -gq "@macos_network_speed_rx" $n_rx

upload_speed=$(get_speed $n_tx $c_tx)
download_speed=$(get_speed $n_rx $c_rx)

download_color=$(get_tmux_option "@macos_network_speed_download_color" "$default_download_color")
upload_color=$(get_tmux_option "@macos_network_speed_upload_color" "$default_upload_color")

printf "%s↓ %s %s↑ %s#[fg=default]" "$download_color" "$download_speed" "$upload_color" "$upload_speed"
