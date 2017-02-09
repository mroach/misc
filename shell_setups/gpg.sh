# Ensure GNU Privacy Guard will work
# The agent will cache the key so you're not prompted constantly for the passphrase
which gpg-agent &>/dev/null

if [ $? -eq 0 ]; then
  export GPG_AGENT_INFO=$HOME/.gnupg/S.gpg-agent
  export GPG_TTY=$(tty)
  gpg-connect-agent /bye &>/dev/null || gpg-agent --daemon &>/dev/null
fi
