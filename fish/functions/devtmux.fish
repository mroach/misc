function devtmux
    # create a session name based on the dirname. remove chars not valid for a session name
    set session_name (basename $PWD | sed -E "s/[^a-z0-9]+/_/g")

    # if a session already exists with this name, attach.
    # otherwise you end up creating quite a messy window setup
    if test (tmux ls -F "#{session_name}" | grep -c \^{$session_name}\$) -gt 0
      echo "Session already exists with this name. Attaching..."
      sleep 2
      tmux attach-session -t "$session_name"
      return 0
    end

    tmux set-option remain-on-exit on

    # create a new session in deatched mode named after the pwd
    # we'll attach at the end once it's all setup
    tmux new-session -d -s "$session_name"

    # create a new window split horizontally
    tmux split-window -h

    # and then create one more window split vertically
    tmux split-window -v

    # create a new window and run tig (text interface to git)
    # tmux new-window 'tig'

    # switch back to the first window
    tmux select-window -t :0

    # and re-attach the session now that it's all setup
    tmux -2 attach-session -t "$session_name"
end
