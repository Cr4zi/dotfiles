#!/bin/sh
# A dmenu script for launching config files.

CEDITOR="emacs"

declare -a options=(
    "alacritty - ~/.config/alacritty/alacritty.yml"
    "qtile - ~/.config/qtile/config.py"
    "emacs config.el - ~/.doom.d/config.el"
    "emacs init.el - ~/.doom.d/init.el"
    "emacs packages.el - ~/.doom.d/packages.el"
    "dmenu - ~/.config/dmenu/config.h"
    "dunst - ~/.config/dunst/dunstrc"
    "nvim - ~/.config/nvim/init.vim"
)

choice=$(printf '%s\n' "${options[@]}" | dmenu -i -l 20 -p 'Launch Config: ')

if [[ "$choice" == "quit" ]]; then
    echo "Quit" && exit 1
elif [ "$choice" ]; then
    cfg=$(printf '%s\n' "$choice" | awk '{print $NF}')
    $CEDITOR "$cfg"
else
    echo "Quit" && exit 1
fi
