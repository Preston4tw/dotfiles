#!/bin/bash

homeshick cd dotfiles
cd ..
git submodule init
git submodule update --depth 1 file:///Users/pbennes/github/solarized &&
git config --file .git/modules/solarized/config core.sparsecheckout true &&
[ -d .git/modules/solarized/info/ ] &&
cat > .git/modules/solarized/info/sparse-checkout << EOF
/CHANGELOG.mkd
/DEVELOPERS.mkd
/LICENSE
/README.md
/iterm2-colors-solarized/
/tmux/
/vim-colors-solarized/
EOF
[ $? -eq 0 ] && git submodule foreach git read-tree -mu HEAD
