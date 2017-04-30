#!/bin/bash

# Install Homebrew
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# Ruby development:
# rbenv, ruby 2.3.1, bundler, mailcatcher
brew install rbenv
$(rbenv init -)
rbenv install 2.3.1
rbenv shell 2.3.1
gem update --system
gem install bundler
gem install mailcatcher

# Bunch of dev dependencies
brew install node
brew install zsh
brew install pow
brew install gnupg2
brew install tmux
brew install git
brew install reattach-to-user-namespace
brew install terminal-notifier
brew install tig
brew install phantomjs
brew install imagemagick
brew install httpie
brew install axel
brew install nmap
brew install mkvtoolnix

npm install bower -g

# PostgreSQL 9.5 since that's what version we run in production on Ubuntu 16 LTS
brew install postgresql@9.5
brew services start postgresql@9.5

# oh my zsh and spaceship theme
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
curl -o - https://raw.githubusercontent.com/denysdovhan/spaceship-zsh-theme/master/install.sh | zsh

# get basics setup
mkdir -p ~/workspace/mroach
git clone git@github.com:mroach/misc.git ~/workspace/mroach/misc
source ~/workspace/mroach/misc/setup.sh

brew cask install iterm2
brew cask install sublime-text
brew cask install the-unarchiver
brew cask install vlc
brew cask install 1password
brew cask install dropbox
brew cask install beamer

curl get.pow.cx | sh

# Iosevka font (using in iTerm and Sublime Text)
curl -OL https://github.com/be5invis/Iosevka/releases/download/v1.11.3/iosevka-pack-1.11.3.zip && \
	unzip iosevka-pack-1.11.3.zip -d Library/Fonts && \
	rm iosevka-pack-1.11.3.zip

# Source Code Pro (sometimes use it in Sublime Text)
curl -OL https://github.com/adobe-fonts/source-code-pro/archive/2.030R-ro/1.050R-it.zip && \
	unzip 1.05R-it.zip && \
	cp source-code-pro-2.030R-ro-1.050R-it/OTF/SourceCodePro-* Library/Fonts && \
	rm -rf source-code-pro-2.030R-ro-1.050R-it && \
	rm 1.05R-it.zip

# sublime packages:
# gitgutter, alignment, brackethighligher, sidebarenhancements, boxy, ruby slim

# Now configure macOS
source configure_osx.sh

# Install quicklook helpers
brew cask install qlcolorcode qlstephen qlmarkdown quicklook-json qlprettypatch quicklook-csv betterzipql qlimagesize webpquicklook suspicious-package qlvideo

# Lastrly, enable TRIM support which results in an immediate reboot
sudo trimforce enable
