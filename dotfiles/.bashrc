export TERM=xterm-256color

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

test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"

source $HOME/workspace/mroach/misc/shell_setups/config.sh
source $HOME/workspace/mroach/misc/shell_setups/langenv.sh
source $HOME/workspace/mroach/misc/shell_setups/homebrew.sh
source $HOME/workspace/mroach/misc/shell_setups/tmux_setups.sh
source $HOME/workspace/mroach/misc/shell_setups/pow.sh
source $HOME/workspace/mroach/misc/shell_setups/ssh.sh
source $HOME/workspace/mroach/misc/shell_setups/gpg.sh
