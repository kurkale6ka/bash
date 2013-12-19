#! /bin/sh
# Author: Dimitar Dimitrov
#         kurkale6ka

export SHELL=/bin/bash

export PATH="$PATH":"$HOME"/bin

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

# -r  : --raw-control-chars
# -i  : ignore case
# -M  : ruler
# -F  : quit if 1 screen
# -PM : long prompt
# ?letterCONTENT. - if test true display CONTENT (the dot ends the test) OR
# ?letterTRUE:FALSE.
# ex: ?L%L lines, . - if number of lines known: display %L lines,
export LESS='-r -i -M -F -PM?f%f - :.?L%L lines, .?ltL\:%lt:.?pB, %pB\% : .?e(Bottom)%t'

export LIBVIRT_DEFAULT_URI=qemu:///system

# Needs installing x11-ssh-askpass
# TODO: fix keyboard layout issue
if [ -n "$SSH_ASKPASS" ] && test -x "$(command -v keychain)"; then
   eval "$(keychain --eval --agents ssh -Q --quiet id_rsa id_rsa_git)"
fi

# Business specific or system dependant stuff
[ -r "$HOME"/.bash_profile_after ] && . "$HOME"/.bash_profile_after

[ -r "$HOME"/.bashrc ] && . "$HOME"/.bashrc
