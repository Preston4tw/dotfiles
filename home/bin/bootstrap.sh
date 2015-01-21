#!/bin/bash

git clone https://github.com/andsens/homeshick.git "${HOME}/.homesick/repos/homeshick"
source "$HOME/.homesick/repos/homeshick/homeshick.sh"
homeshick clone https://github.com/Preston4tw/dotfiles.git
