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

export ZPLUG_HOME=/usr/local/opt/zplug
source $ZPLUG_HOME/init.zsh

zplug "woefe/git-prompt.zsh"
zplug "zsh-users/zsh-syntax-highlighting", defer:2

zplug load 

source /usr/local/opt/fzf/shell/completion.zsh
source /usr/local/opt/fzf/shell/key-bindings.zsh

source ~/.config/zsh/devtmux.zsh
source ~/.config/zsh/path.zsh

bindkey "^[b" backward-word
bindkey "^[f" forward-word
bindkey "^A" beginning-of-line
bindkey "^E" end-of-line
