#!/usr/bin/env zsh

os="unknown"

case "$(uname)" in
    Darwin)
        os="macos"
        ;;
    Linux)
        os="linux"
        ;;
    *)
        os="unknown"
        ;;
esac

if [ "$os" = "macos" ]; then
    PATH="/usr/local/opt/ruby/bin:/usr/local/lib/ruby/gems/2.6.0/bin:$PATH"
fi

export PATH=$PATH
