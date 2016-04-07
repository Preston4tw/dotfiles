# https://google.github.io/styleguide/shell.xml

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# Pull in tiny files under ~/.bash
for tiny_file in "${HOME}"/.bash/*.sh; do
  if [[ -f "${tiny_file}" ]] && [[ ! -x "${tiny_file}" ]]; then
    source ${tiny_file}
  fi
done

# Don't bleed vars into the environment unnecessarily
unset tiny_file
