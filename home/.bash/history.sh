# vim: tabstop=2 softtabstop=2 shiftwidth=2 expandtab autoindent
# Style guide: https://google.github.io/styleguide/shell.xml
#
# Description:
#
#


# Only run if we're being sourced
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
  echo "This is meant to be sourced, not executed directly. Exiting." >&2
  exit 1
fi

function include_guard() {
  # This function provides an include guard so that if desired this script will
  # only be sourced once. This is useful for cases where include files might be
  # run multiple times if subshells are executed such as when using screen or
  # tmux.
  #
  # This functionality is implemented by creating and exporting a check variable
  # named after the name of this file with prefix DOTBASH
  local this_filename="$(basename $(echo ${BASH_SOURCE} | tr '[a-z]' '[A-Z]'))"
  local check_var="DOTBASH_${this_filename}"
  if [ -z ${!check_var:-} ]; then
    # check_var is undefined. define it and return zero indicating the script
    # should continue.
    # -g  make variable global (needed when using declare in a func)
    # -r  make variable readonly
    # -x  export variable
    declare -grx ${check_var}=1
    return 0
  else
    return 1
  fi
}

function main() {
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
}

# This appears to need to be run on every invocation?
# Force prompt to write history after every command.
# http://superuser.com/questions/20900/bash-history-loss
PROMPT_COMMAND="history -a; $PROMPT_COMMAND"

# If this should only ever be sourced once (handling subshells, screen, tmux,
# etc)
include_guard && main

# Or if being sourced repeatedly is fine
# main
