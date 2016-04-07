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
  # Mac
  [ "$(uname -s)" = "Darwin" ] && source $(dirname ${BASH_SOURCE[0]})/platform/mac

  # Crouton / ChromeOS
  if [ -d /proc ] && [ -e /proc/cmdline ] && grep -q '^cros_secure' /proc/cmdline; then
    source $(dirname ${BASH_SOURCE[0]})/platform/crouton
  fi
}

# If this should only ever be sourced once (handling subshells, screen, tmux,
# etc)
#include_guard && main

# Or if being sourced repeatedly is fine
main
