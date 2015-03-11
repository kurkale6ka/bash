#! /bin/sh
# Author: Dimitar Dimitrov
#         kurkale6ka

if ! grep "$HOME"/bin <<< "$PATH" >/dev/null
then
   export PATH="$HOME"/bin:"$PATH"
fi

export PYTHONSTARTUP="$HOME"/.pyrc

export LANG=en_GB.UTF-8
export LC_COLLATE=C

# Remove w permissions for group and others
# file      default: 666 (-rw-rw-rw-) => 644 (-rw-r--r--)
# directory default: 777 (drwxrwxrwx) => 755 (drwxr-xr-x)
umask 022

export EDITOR="vim -u $HOME/.vimrc"
export VISUAL="vim -u $HOME/.vimrc"
export MYVIMRC="$HOME"/.vimrc
export MYGVIMRC="$HOME"/.gvimrc

export PS_PERSONALITY=bsd
export PS_FORMAT=pid,ppid,pgid,sid,tname,tpgid,stat,euser,egroup,start_time,cmd

# -i   : ignore case
# -r/R : raw control characters
# -s   : Squeeze multiple blank lines
# -W   : Highlight first new line after any forward movement
# -M   : very verbose prompt
# -PM  : customize the very verbose prompt (there is also -Ps and -Pm)
# ?letterCONTENT. - if test true display CONTENT (the dot ends the test) OR
# ?letterTRUE:FALSE.
# ex: ?L%L lines, . - if number of lines known: display %L lines,
export LESS='-i -r -s -W -M -PM?f%f - :.?L%L lines, .?ltL\:%lt:.?pB, %pB\% : .?e(Bottom)%t'

# Needs installing x11-ssh-askpass
# TODO: fix keyboard layout issue
if [ -n "$SSH_ASKPASS" ] && test -x "$(command -v keychain)"; then
   setxkbmap -layout gb
   eval "$(keychain --eval --agents ssh -Q --quiet id_rsa id_rsa_git)"
fi

# Business specific or system dependant stuff
[ -r "$HOME"/.bash_profile_after ] && . "$HOME"/.bash_profile_after

[ -r "$HOME"/.bashrc ] && . "$HOME"/.bashrc
