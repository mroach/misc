# Ensure GNU Privacy Guard will work
# The agent will cache the key so you're not prompted constantly for the passphrase
which gpg-agent &>/dev/null

if [ $? -ne 0 ]; then exit; fi

export GPG_TTY=$(tty)

pgrep -q gpg-agent
if [ $? -eq 0 ]; then
  source $HOME/.gpg-agent-info
  export GPG_AGENT_INFO
  gpg-connect-agent /bye &>/dev/null
else
  gpg-agent --daemon &>/dev/null
  export GPG_AGENT_INFO
fi
