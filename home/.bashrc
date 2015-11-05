# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# Bash history settings
[ -f .bash/history ] && source .bash/history

# Add ~/bin to PATH with priority if it exists
if [ -d "$HOME/bin" ]; then
  PATH="$HOME/bin:$PATH"
fi

# Aliases
[ -f .bash/aliases ] && source .bash/aliases

if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

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

export EDITOR=vim

source "$HOME/.homesick/repos/homeshick/homeshick.sh"

# Platform specific
if [ -d /proc] && [ -e /proc/cmdline ] && grep -q '^cros_secure' /proc/cmdline; then
  [ -f ~/.bash/crouton ] && source ~/.bash/crouton
fi

# Shit to review
cat <<'EOF'>/dev/null
# notify of bg job completion immediately
set -o notify

# Don't care about mail
unset MAILCHECK

# Disable core dumps
ulimit -S -c 0

# Make sure umask is sane
umask 0022

# we want the various sbins on the path along with /usr/local/bin
PATH="$PATH:/usr/local/sbin:/usr/sbin:/sbin"
PATH="/usr/local/bin:$PATH"

# put ~/bin on PATH if you have it
test -d "$HOME/bin" &&
PATH="$HOME/bin:$PATH"

# enable en_US locale w/ utf-8 encodings if not already configured
: ${LANG:="en_US.UTF-8"}
: ${LANGUAGE:="en"}
: ${LC_CTYPE:="en_US.UTF-8"}
: ${LC_ALL:="en_US.UTF-8"}
export LANG LANGUAGE LC_CTYPE LC_ALL

# See what we have to work with ...
HAVE_VIM=$(command -v vim)
HAVE_GVIM=$(command -v gvim)

# EDITOR
test -n "$HAVE_VIM" &&
EDITOR=vim ||
EDITOR=vi
export EDITOR

# PAGER
if test -n "$(command -v less)" ; then
    PAGER="less -FirSwX"
    MANPAGER="less -FiRswX"
else
    PAGER=more
    MANPAGER="$PAGER"
fi
export PAGER MANPAGER


# ----------------------------------------------------------------------
# PROMPT
# ----------------------------------------------------------------------

RED="\[\033[0;31m\]"
BROWN="\[\033[0;33m\]"
GREY="\[\033[0;97m\]"
BLUE="\[\033[0;34m\]"
PS_CLEAR="\[\033[0m\]"
SCREEN_ESC="\[\033k\033\134\]"

if [ "$LOGNAME" = "root" ]; then
    COLOR1="${RED}"
    COLOR2="${BROWN}"
    P="#"
elif hostname | grep -q 'github\.com'; then
    GITHUB=yep
    COLOR1="\[\e[0;94m\]"
    COLOR2="\[\e[0;92m\]"
    P="\$"
else
    COLOR1="${BLUE}"
    COLOR2="${BROWN}"
    P="\$"
fi

prompt_simple() {
    unset PROMPT_COMMAND
    PS1="[\u@\h:\w]\$ "
    PS2="> "
}

prompt_compact() {
    unset PROMPT_COMMAND
    PS1="${COLOR1}${P}${PS_CLEAR} "
    PS2="> "
}

prompt_color() {
    PS1="${GREY}[${COLOR1}\u${GREY}@${COLOR2}\h${GREY}:${COLOR1}\W${GREY}]${COLOR2}$P${PS_CLEAR} "
    PS2="\[[33;1m\] \[[0m[1m\]> "
}

# ----------------------------------------------------------------------
# MACOS X / DARWIN SPECIFIC
# ----------------------------------------------------------------------

if [ "$UNAME" = Darwin ]; then
    # setup java environment. puke.
    export JAVA_HOME="/System/Library/Frameworks/JavaVM.framework/Home"

    # hold jruby's hand
    test -d /opt/jruby &&
    export JRUBY_HOME="/opt/jruby"
fi

# ----------------------------------------------------------------------
# ALIASES / FUNCTIONS
# ----------------------------------------------------------------------

# disk usage with human sizes and minimal depth
alias du1='du -h --max-depth=1'
alias fn='find . -name'
alias hi='history | tail -20'


# ----------------------------------------------------------------------
# LS AND DIRCOLORS
# ----------------------------------------------------------------------

# we always pass these to ls(1)
LS_COMMON="-hBG"

# if the dircolors utility is available, set that up to
dircolors="$(type -P gdircolors dircolors | head -1)"
test -n "$dircolors" && {
    COLORS=/etc/DIR_COLORS
    test -e "/etc/DIR_COLORS.$TERM"   && COLORS="/etc/DIR_COLORS.$TERM"
    test -e "$HOME/.dircolors"        && COLORS="$HOME/.dircolors"
    test ! -e "$COLORS"               && COLORS=
    eval `$dircolors --sh $COLORS`
}
unset dircolors

# setup the main ls alias if we've established common args
test -n "$LS_COMMON" &&
alias ls="command ls $LS_COMMON"

# these use the ls aliases above
alias ll="ls -l"
alias l.="ls -d .*"
EOF
