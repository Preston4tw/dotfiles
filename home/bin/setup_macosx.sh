#!/bin/bash

set -o pipefail
set -o errexit
set -o nounset

# Only run on Mac OS X
[ "$(uname -s)" = "Darwin" ]

# It may make sense to limit this script to particular versions of mac os x at
# some point:
# sw_vers -productVersion
# 10.10.5

# Modify sudoers so all the rest of this stuff that would normally prompt for
# your password doesn't, only if it's not already set

# nuke cached sudo password so this next bit executes properly if NOPASSWD isn't
# set but password is cached
sudo -K
# try and sudo without password
if ! sudo -n true; then
  echo 'Setting NOPASSWD for admin group in sudoers'
  sudo sed -i '' 's/^%admin.*/%admin ALL=(ALL) NOPASSWD:ALL/' /etc/sudoers
fi

# Install Xcode Command Line Tools for git for homesick
# http://apple.stackexchange.com/a/195963
# https://github.com/chcokr/osx-init/blob/master/install.sh
# https://github.com/timsutton/osx-vm-templates/blob/ce8df8a7468faa7c5312444ece1b977c1b2f77a4/scripts/xcode-cli-tools.sh
if ! [ -x /usr/bin/git ]; then
  touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
  CLI_TOOLS_NAME=$(
    softwareupdate -l |
    awk -F\* '/\* Command Line Tools / {
      sub(/^ /, "", $2);
      sub(/\n/, "", $2);
      printf("%s",$2);
    }'
  )
  softwareupdate -i "${CLI_TOOLS_NAME}" -v;
fi

# Setup dotfiles via homeshick and personal dotfiles repo
if ! [ -d "${HOME}/.homesick/repos/homeshick/.git" ]; then
  git clone https://github.com/andsens/homeshick.git "${HOME}/.homesick/repos/homeshick"
fi
if ! [ -d "${HOME}/.homesick/repos/dotfiles/.git" ]; then
  source "$HOME/.homesick/repos/homeshick/homeshick.sh"
  homeshick -b clone https://github.com/Preston4tw/dotfiles.git
fi

# Install homebrew if it's not installed
if ! [ -x /usr/local/bin/brew ]; then
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

# Homebrew installs
BREWS="
bash
tmux
awscli
caskroom/cask/brew-cask
"
for brew in ${BREWS}; do
  brew list ${brew} || brew install ${brew} || true
done

# Update our default shell to brew bash
echo /usr/local/bin/bash >> /etc/shells
chpass -s /usr/local/bin/bash $(whoami)


# Install some software with brew-cask
CASKS="
iterm2
virtualbox
vagrant
keepassx
"
for cask in ${CASKS}; do
  # We don't care if one of these installs fails
  brew cask install $cask || true
done
brew install bash
brew install bash tmux awscli
sudo gem install veewee