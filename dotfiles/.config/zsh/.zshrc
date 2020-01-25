# Lines configured by zsh-newuser-install
HISTFILE=~/.cache/.histfile
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory
unsetopt beep
bindkey -v
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/Users/michael.roach/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

export ZPLUG_HOME=/usr/local/opt/zplug
source $ZPLUG_HOME/init.zsh

zplug "woefe/git-prompt.zsh"
zplug "zsh-users/zsh-syntax-highlighting", defer:2

zplug load 

source /usr/local/opt/fzf/shell/completion.zsh
source /usr/local/opt/fzf/shell/key-bindings.zsh

source ~/.config/zsh/devtmux.zsh
source ~/.config/zsh/path.zsh
