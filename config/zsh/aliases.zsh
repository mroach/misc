
__command_exists() {
  (( $+commands[$1] ))
}

alias g='git'

# options differ between ls in GNU and BSD
if ls --version 2>&1 | grep GNU &>/dev/null; then
    alias ls='ls --classify --color=auto --almost-all --human-readable'
else
    alias ls='ls -AFG'
fi

# ensure command: open
# purpose: open a resource with the default viewer
# example: open ~/downloads/info.pdf
if ! __command_exists open; then
  if __command_exists xdg-open; then
    alias open='xdg-open'
  fi
fi

# ensure command: pbcopy
# purpose: copy text to the clipboard
# example: curl httbin.org/uuid | pbcopy
if ! __command_exists pbcopy; then
  # wayland
  __command_exists wl-copy && alias pbcopy='wl-copy'

  # x11
  __command_exists xclip && alias pbcopy='xclip -selection c'
fi

# ensure command: pbpaste
# purpose: paste text from the clipboard
# example: echo "the clipboard contents are $(pbpaste)"
if ! __command_exists pbpaste; then
  # wayland
  __command_exists wl-paste && alias pbcopy='wl-paste'

  # x11
  __command_exists xclip && alias pbpaste='xclip -selection clipboard -o'
fi

if [ "$TERM" = "xterm-kitty" ]; then
  alias icat="kitty +kitten icat"
fi
