function dev-tmux() {
    # create a session name based on the dirname. remove chars not valid for a session name
    _session_name=$(echo `basename $PWD` | sed -E "s/[^a-z0-9]+/_/g")
    tmux set-option remain-on-exit on

    # create a new session. run guard if available
    #tmux new-session -d -s "$_session_name" 'test -e Guardfile && bundle exec guard'
    tmux new-session -d -s "$_session_name"

    # create a new window, run the rails console if available
    tmux split-window -h 'test -e bin/rails && bundle exec rails c'

    # and then create one more window and leave it blank
    tmux split-window -v

    # create a new window and run tig (text interface to git)
    tmux new-window 'tig'

    # switch back to the first window
    tmux select-window -t :0

    # and re-attach the session now that it's all setup
    tmux -2 attach-session -t "$_session_name"
}
