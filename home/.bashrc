# Unlimited bash history
export HISTCONTROL="ignoreboth"
export HISTFILESIZE=
export HISTSIZE=
# %F  Equivalent to %Y-%m-%d (the ISO 8601 date format). (C99)
# %T  The time in 24-hour notation (%H:%M:%S). (SU)
export HISTTIMEFORMAT="[%F %T] "
# Change the file location because certain bash sessions truncate .bash_history file upon close.
# http://superuser.com/questions/575479/bash-history-truncated-to-500-lines-on-each-login
export HISTFILE=~/.bash_eternal_history
# Force prompt to write history after every command.
# http://superuser.com/questions/20900/bash-history-loss
PROMPT_COMMAND="history -a; $PROMPT_COMMAND"

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# Add ~/bin to PATH with priority if it exists
if [ -d "$HOME/bin" ]; then
  PATH="$HOME/bin:$PATH"
fi

# enable color support of ls/grep and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some more ls aliases
alias ll='ls -l'
alias la='ls -A'
alias l='ls -CF'

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

alias homeshick="source ${HOME}/.homesick/repos/homeshick/bin/homeshick.sh"

# shopt
# -s set, aka enable
# -u unset, aka disable
# If command is just a dirname, assume cd
# autocd
# Check for stopped/backgrounded jobs before exiting interactive shell
shopt -s checkjobs
# Checks window size after each command, updates LINES/COLUMNS if necessary
shopt -s checkwinsize
# Tries to append all lines of a multi-line command in the same hist entry
shopt -s cmdhist
# Behave like bash $version
# compat(31|32|40|41)
# Append instead of overwrite HISTFILE
shopt -s histappend

# What bash version are we working with?
# echo $BASH_VERSINFO
