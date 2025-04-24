#!/usr/bin/env bash

function computeRelativePositions() {
    # game_window=$(hyprctl clients -j | jq -c '.[] | select(.title == "Cornerpond")')
    game_window=$(hyprctl clients -j | jq -c '.[] | select(.class == "steam_app_3454590")')
    gw_pos_x=$(echo "$game_window" | jq '.at[0]')
    gw_pos_y=$(echo "$game_window" | jq '.at[1]')

    gw_width=$(echo "$game_window" | jq '.size[0]')
    gw_height=$(echo "$game_window" | jq '.size[1]')

    # Final divide by 2 because for some reason ydotool mousemove takes actual pos / 2

    bait_btn_pos_x=$(echo "($gw_pos_x + $gw_width * 0.78) / 2" | bc)
    bait_btn_pos_y=$(echo "($gw_pos_y + $gw_height * 0.78) / 2" | bc)

    fish_btn_pos_x=$(echo "($gw_pos_x + $gw_width * 0.42) / 2" | bc)
    fish_btn_pos_y=$(echo "($gw_pos_y + $gw_height * 0.78) / 2" | bc)

    sell_all_btn_pos_x=$(echo "($gw_pos_x + $gw_width * 0.7) / 2" | bc)
    sell_all_btn_pos_y=$(echo "($gw_pos_y + $gw_height * 0.33) / 2" | bc)

    reset_pos_x=$(echo "($gw_pos_x + $gw_width * 0.1) / 2" | bc)
    reset_pos_y=$(echo "($gw_pos_y + $gw_height * 0.1) / 2" | bc)
}

function showBanner() {
    echo "Cornerpond AutoFisher" | figlet | lolcat -S 22
}

function sellAllFish() {
    # click blue fish UI button
    ydotool mousemove -a -x "$fish_btn_pos_x" -y "$fish_btn_pos_y" \
        && sleep 0.1s && ydotool click 0xC0 > /dev/null
    sleep 0.2s

    # click big Sell All UI button
    ydotool mousemove -a -x "$sell_all_btn_pos_x" -y "$sell_all_btn_pos_y" \
        && sleep 0.1s && ydotool click 0xC0 > /dev/null
    sleep 0.2s

    # click empty space to close the GUI
    ydotool mousemove -a -x "$reset_pos_x" -y "$reset_pos_y" \
        && sleep 0.1s && ydotool click 0xC0 > /dev/null
}

function refillBait() {
    # click refill bait button
    ydotool mousemove -a -x "$bait_btn_pos_x" -y "$bait_btn_pos_y" && sleep 0.1s && ydotool click 0xC0 > /dev/null
}

function fullAutomate() {
    computeRelativePositions
    refillBait && sleep 0.5s && sellAllFish
}

function showHelp() {
    echo -e "Usage: cornerpond-afk.sh OPTION\n"
    echo "-h, --help        display this help text and exit"
    echo "-l, --loop        launch in forever loop mode"
    echo "-o, --once        launch only once"
}

if [[ "$1" = "-h" || "$1" = "--help" ]]; then
    showHelp
    exit 0
fi

if [[ "$1" = "-l" || "$1" = "--loop" ]]; then
    showBanner

    counter=0
    echo "♾️ Starting infinite loop (stop with CTRL+C)"
    sleep 1s

    while true; do
        echo "🎣 READY? (5s)" 
        sleep 5s
        echo "🐟 Executing automation! $counter"
        fullAutomate
        echo "😴 Sleep for 60s..."
        sleep 60s
        ((counter++))
    done
elif [[ "$1" = "-o" || "$1" = "--once" ]]; then
    showBanner
    echo "✨ Executing automation once..."
    fullAutomate
    echo "✅ Automation END"
else
    echo "unknown option: $1"
    showHelp
    exit 1
fi
