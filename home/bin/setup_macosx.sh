#!/bin/bash -x

# Defensive bash
set -o pipefail
set -o errexit
set -o nounset

# Only run on Mac OS X
[ "$(uname -s)" = "Darwin" ]

# Possible inspiration:
# https://github.com/chcokr/osx-init/blob/master/install.sh

# System Preferences, programatically =D
# defaults write
#   com.apple.AppleMultitouchTrackpad
#   com.apple.dock
#   com.apple.finder
#   com.googlecode.iterm2
#   
# Apple Global Domain
#   com.apple.swipescrolldirection = 0
defaults write 'Apple Global Domain' com.apple.swipescrolldirection -int 0
# com.apple.AppleMultitouchTrackpad
#   Clicking=1
defaults write com.apple.AppleMultitouchTrackpad Clicking -int 1
#   TrackpadFiveFingerPinchGesture=0
defaults write com.apple.AppleMultitouchTrackpad TrackpadFiveFingerPinchGesture -int 0
#   TrackpadFourFingerPinchGesture=0
defaults write com.apple.AppleMultitouchTrackpad TrackpadFourFingerPinchGesture -int 0
# com.apple.dock
#   showAppExposeGestureEnabled=0
defaults write com.apple.dock showAppExposeGestureEnabled -int 0
#   showDesktopGestureEnabled=0
defaults write com.apple.dock showDesktopGestureEnabled -int 0
#   showLaunchpadGestureEnabled=0
defaults write com.apple.dock showLaunchpadGestureEnabled -int 0
# com.apple.systempreferences
#   trackpad.lastselectedtab=0
defaults write com.apple.systempreferences trackpad.lastselectedtab -int 0

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
if ! sudo -n true &>/dev/null; then
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
colordiff
"
for brew in ${BREWS}; do
  brew list ${brew} || brew install ${brew} || true
done

# Update our default shell to brew bash
if ! grep -q '/usr/local/bin/bash' /etc/shells; then
  echo /usr/local/bin/bash | sudo tee -a /etc/shells
fi

CUR_SHELL="$(dscl -q . -read /Users/$(whoami) UserShell | awk -F': ' '{ print $2}')"
if [ "${CUR_SHELL}" != "/usr/local/bin/bash" ]; then
  sudo chpass -s /usr/local/bin/bash $(whoami)
fi

# Install some software with brew-cask
CASKS="
iterm2
virtualbox
vagrant
keepassx
smcfancontrol
"
for cask in ${CASKS}; do
  # We don't care if one of these installs fails
  brew cask install $cask || true
done

if ! gem list veewee | grep -q '^veewee '; then
  sudo gem install veewee
fi
