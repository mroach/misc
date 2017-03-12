#!/bin/bash

# Sets-up symlinks for all the goodies in this repo!

# get 'root' dir by finding the dir this script is in
# this will allow us to create symlinks with full paths
SRCDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

ln -s $SRCDIR/dotfiles/.gnupg/gpg-agent.conf $HOME/.gnupg/gpg-agent.conf
ln -s $SRCDIR/dotfiles/.gitconfig $HOME/.gitconfig
ln -s $SRCDIR/dotfiles/.grc.bashrc $HOME/.grc.bashrc
ln -s $SRCDIR/dotfiles/.tmux.conf $HOME/.tmux.conf
ln -s $SRCDIR/dotfiles/.bashrc $HOME/.bashrc
ln -s $SRCDIR/dotfiles/.zshrc $HOME/.zshrc
ln -s $SRCDIR/dotfiles/.gemrc $HOME/.gemrc

# .bash_profile is executed for login shells; .bashrc is executed for interactive non-login shells
# ensure both are using the same configuration
ln -s $HOME/.bashrc $HOME/.bash_profile
