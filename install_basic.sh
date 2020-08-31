#!/bin/bash

packages="curl wget vim git htop tmux fish jq rg"

platform=$(uname -s)

if [ "$platform" == "Darwin" ]; then
  if hash brew 2>/dev/null; then
    echo "homebrew already installed"
  else
    echo "Installing homebrew..."
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  fi
  brew install $packages

elif [ "$platform" == "Linux" ]; then
  distro=$(grep '^ID=' /etc/os-release | cut -d= -f2)

  case $distro in
    Debian | Ubuntu)
      sudo apt-get install $packages ;;
    *)
      echo "Can't auto-install on $distro" ;;
  esac
fi
