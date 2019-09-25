# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
#ZSH_THEME="powerlevel9k/powerlevel9k"
ZSH_THEME='spaceship'

GIT_PS1_SHOWUPSTREAM="auto"

SPACESHIP_BATTERY_SHOW=false
SPACESHIP_KUBECONTEXT_SHOW=false
SPACESHIP_NODE_SHOW=false
SPACESHIP_PYENV_SHOW=false
SPACESHIP_RUBY_SHOW=false
SPACESHIP_PYENV_SHOW=false
SPACESHIP_DIR_TRUNC=8

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
HIST_STAMPS="yyyy-mm-dd"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(brew bundler cap dirhistory gem git gitfast git-extras rails)

if [ -f $ZSH/oh-my-zsh.sh ]; then
  source $ZSH/oh-my-zsh.sh
fi

source $HOME/workspace/mroach/misc/shell_setups/config.sh
source $HOME/workspace/mroach/misc/shell_setups/langenv.sh
source $HOME/workspace/mroach/misc/shell_setups/homebrew.sh
source $HOME/workspace/mroach/misc/shell_setups/tmux_setups.sh
source $HOME/workspace/mroach/misc/shell_setups/pow.sh
source $HOME/workspace/mroach/misc/shell_setups/ssh.sh
source $HOME/workspace/mroach/misc/shell_setups/gpg.sh
