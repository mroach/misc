LOCAL=${HOME}/local
BASEPATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/bin:${HOME}/bin:/sbin:/usr/sbin
PATH=${LOCAL}/bin:${LOCAL}/sbin:${BASEPATH}:${HOME}/usr/bin:/Developer/usr/bin:${HOME}/android-sdk-macosx/platform-tools
MANPATH=${MANPATH}:/opt/local/share/man
POWERLINE_PATH="${HOME}/workspace/powerline-shell/powerline-shell.py"

export PATH

export TERM=xterm-256color

# vim > nano, obviously
export EDITOR=vim
export PAGER=less

# pow configuration. (http://pow.cx)
export POW_DOMAINS=dev,pow
export POW_EXT_DOMAINS=lvh.me

# Nicer prompt generation
PS1_HOST='\h'
PS1_DIR='\[\e[1;36m\]\w\[\e[0m\]'
PS1_HAPPY='\[\e[;32m\]'
PS1_SAD='\[\e[;31m\]'
PS1_RED='\[\e[;31m\]'

PS1_MAKEHOST() {
  # If the last command failed, show in red
  if [ $? -ne 0 ]; then
    echo -e "${PS1_SAD}${PS1_HOST}${PS1_SAD}"
  else
    echo -e "${PS1_HAPPY}${PS1_HOST}${PS1_HAPPY}"
  fi
}

PS1_MAKEDIR() {
  echo -e "${PS1_RED}[${PS1_DIR}${PS1_RED}]"
}

PS1_MAKE() {
  PS1="`PS1_MAKEHOST` `PS1_MAKEDIR` \[\e[0m\]\\$ "
}

POWERLINE_INIT() {
  export PS1="$($POWERLINE_PATH $? 2> /dev/null)"
}

# If powerline is available, use it
# Otherwise, use the decent one we defined above
if [ -f "$POWERLINE_PATH" ]; then
  export PROMPT_COMMAND=POWERLINE_INIT
else
  export PROMPT_COMMAND=PS1_MAKE
fi

# Alias ls to make it better
if [ `uname` = "Darwin" -o `uname` = "FreeBSD" ]; then
  alias ls='ls -FAG'
else
  alias ls='ls --classify --color=always'
fi

# Colourise grep
export GREP_OPTIONS='--color=auto'

# More colours!
test -e ~/.grc.bashrc && source ~/.grc.bashrc

# Bells are annoying af
set vbell off
set abell off

# Ensure ssh keys are added
ssh-add -A 2> /dev/null

# Init rbenv and pyenv if available
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi
if which pyenv > /dev/null; then eval "$(pyenv init -)"; fi

# Read the API token from the macOS Keychain
# To add: security add-generic-password -a "$USER" -s 'Homebrew GitHub Token' -w 'TOKEN GOES HERE'
export HOMEBREW_GITHUB_API_TOKEN=$(security find-generic-password -s 'Homebrew GitHub Token' -w)

# Ensure GNU Privacy Guard will work
export GPG_TTY=$(tty)

test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"

source "${HOME}/workspace/mroach/misc/bash_helpers/tmux_setups.sh"
