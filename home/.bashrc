# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# Pull in tiny files under ~/.bash
for tiny_file in "${HOME}/.bash/*"; do
  if [ -f "${tiny_file}" ]; then
    source ${tiny_file}
  fi
done
