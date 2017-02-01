function dev-tmux() {
    _session_name=$(echo `basename $PWD` | sed -E "s/[^a-z0-9]+/_/g")
    tmux new-session -d -s "$_session_name"
    tmux split-window -h
    tmux split-window -v
    tmux new-window 'tig'
    tmux select-window -t :0
    tmux -2 attach-session -t "$_session_name"
}
