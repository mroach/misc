#!/bin/bash

# Sets-up symlinks for all the goodies in this repo!

# get 'root' dir by finding the dir this script is in
# this will allow us to create symlinks with full paths
srcdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
platform=$(uname -s)

ln -s $srcdir/dotfiles/.gnupg/gpg-agent.conf $HOME/.gnupg/gpg-agent.conf
ln -s $srcdir/dotfiles/.gitconfig $HOME/.gitconfig
ln -s $srcdir/dotfiles/.grc.bashrc $HOME/.grc.bashrc
ln -s $srcdir/dotfiles/.tmux.conf $HOME/.tmux.conf
ln -s $srcdir/dotfiles/.bashrc $HOME/.bashrc
ln -s $srcdir/dotfiles/.zshrc $HOME/.zshrc
ln -s $srcdir/dotfiles/.gemrc $HOME/.gemrc
ln -s $srcdir/dotfiles/.vimrc $HOME/.vimrc

# .bash_profile is executed for login shells; .bashrc is executed for interactive non-login shells
# ensure both are using the same configuration
ln -s $HOME/.bashrc $HOME/.bash_profile

if [ $platform == "Darwin" ]; then
  ln -s $srcdir/settings/sublime/Preferences.sublime-settings "$HOME/Library/Application Support/Sublime Text 3/Packages/User/Preferences.sublime-settings"
elif [ $platform == "Linux" ]; then
  ln -s $srcdir/settings/sublime/Preferences.sublime-settings "$HOME/.config/sublime-text-3/Packages/User/Preferences.sublime-settings"
fi
