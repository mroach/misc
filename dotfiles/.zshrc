# Lines configured by zsh-newuser-install
HISTFILE=~/.cache/.histfile
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
unsetopt beep
bindkey -v

zstyle :compinstall filename $HOME/.zshrc

autoload -Uz compinit
compinit

function source_if_exists {
  [ -f $1 ] && source $1
}

export ZPLUG_HOME=$HOME/.zplug
source_if_exists $ZPLUG_HOME/init.zsh

zplug "woefe/git-prompt.zsh", use:"{git-prompt.zsh,examples/wprompt.zsh}"
zplug "zsh-users/zsh-syntax-highlighting", defer:2
zplug "bobsoppe/zsh-ssh-agent", use:ssh-agent.zsh, from:github

zplug load

source_if_exists /opt/local/share/fzf/shell/key-bindings.zsh   # MacPorts
source_if_exists /opt/local/share/fzf/shell/completion.zsh
source_if_exists /usr/share/doc/fzf/examples/key-bindings.zsh  # Debian
source_if_exists /usr/share/doc/fzf/examples/completion.zsh

source ~/.config/zsh/completion.zsh
source ~/.config/zsh/devtmux.zsh
source ~/.config/zsh/env.zsh
source ~/.config/zsh/langs.zsh
source ~/.config/zsh/aliases.zsh

# allow overrides on this system that probably aren't version controlled
source_if_exists ~/.zshrc.local

bindkey "^[b" backward-word
bindkey "^[f" forward-word
bindkey "^A" beginning-of-line
bindkey "^E" end-of-line
