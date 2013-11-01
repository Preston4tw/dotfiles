#!/bin/bash

git clone https://github.com/andsens/homeshick.git "${HOME}/.homesick/repos/homeshick"
alias homeshick="source $HOME/.homesick/repos/homeshick/bin/homeshick.sh"
homeshick clone https://github.com/Preston4tw/dotfiles.git
