# Read the API token from the macOS Keychain
# To add: security add-generic-password -a "$USER" -s 'Homebrew GitHub Token' -w 'TOKEN GOES HERE'
export HOMEBREW_GITHUB_API_TOKEN=$(security find-generic-password -s 'Homebrew GitHub Token' -w)
