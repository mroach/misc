function dev-tmux() {
    tmux new-session -d -s "`basename $PWD`"
    tmux split-window -h
    tmux split-window -v
    tmux new-window 'tig'
    tmux select-window -t :0
    tmux -2 attach-session -d
}
