#!/bin/bash
# usage: brightswitch.sh [dark | light]

new_mode=$1

delta_themes=(light dark)
vim_themes=(base16-gruvbox-light-soft base16-ashes)
vim_bg=(light dark)
bat_themes=(OneHalfLight default)
kitten_themes=("Solarized Light" Ayu)
sublime_themes=("gruvbox (Light) (Medium) NDC.sublime-color-scheme" "gruvbox (Dark) (Medium) NDC.sublime-color-scheme")

if [[ "${new_mode}" == "light" ]]; then
  theme_index=0
else
  theme_index=1
fi

# kitty terminal. use `kitty +kitten themes` in a terminal to preview themes
~/.local/bin/kitty +kitten themes --reload-in=all "${kitten_themes[$theme_index]}"

# delta diff tool takes --light or --dark args
sed -i -r "s/(delta.+--)(light|dark)/\1${delta_themes[$theme_index]}/g" ~/.gitconfig

# vim needs a new theme and background light/dark
sed -i -r "/^colorscheme/c colorscheme ${vim_themes[$theme_index]}" ~/.vimrc
sed -i -r "/^set background=/c set background=${vim_bg[$theme_index]}" ~/.vimrc

# bat --list-themes to see what's available
sed -i -r "/^--theme/c --theme ${bat_themes[$theme_index]}" ~/.config/bat/config

# sublime text -- use the switch command
subl --background --command "select_color_scheme {\"name\": \"${sublime_themes[$theme_index]}\"}"
