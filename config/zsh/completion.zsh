if command -v kubectl &>/dev/null ; then
  source <(kubectl completion zsh)
fi

if command -v gh &>/dev/null; then
  source <(gh completion --shell zsh)
fi

if [ -f /usr/share/google-cloud-sdk/completion.zsh.inc ] ; then
  source /usr/share/google-cloud-sdk/completion.zsh.inc
fi
