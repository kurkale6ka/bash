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

. "$HOME"/github/bash/colors

# -r  : --raw-control-chars
# -i  : ignore case
# -M  : ruler
# -F  : quit if 1 screen
# -PM : long prompt
# ?letterCONTENT. - if test true display CONTENT (the dot ends the test) OR
# ?letterTRUE:FALSE.
# ex: ?L%L lines, . - if number of lines known: display %L lines,
export LESS='-r -i -M -F -PM?f%f - :.?L%L lines, .?ltL\:%lt:.?pB, %pB\% : .?e(Bottom)%t'

# Colored man pages
#
# tput smso -> sm so -> set mode stand out (bold)
#      smul -> sm ul -> set mode underline
#      rmso -> rm so -> remove mode stand out...

export LESS_TERMCAP_mb="$LGreen" # begin blinking
export LESS_TERMCAP_md="$LBlue"  # begin bold
export LESS_TERMCAP_me="$Reset"  # end mode

# so -> stand out - info box
export LESS_TERMCAP_so="$(printf %s "$Bold"; tput setaf 3; tput setab 4)"
# se -> stand out end
export LESS_TERMCAP_se="$(tput rmso; printf %s "$Reset")"

# us -> underline start
export LESS_TERMCAP_us="$(printf %s%s "$Bold$Underline"; tput setaf 5)"
# ue -> underline end
export LESS_TERMCAP_ue="$(tput rmul; printf %s "$Reset")"

# export LESS_TERMCAP_mr="$(tput rev)"
# export LESS_TERMCAP_mh="$(tput dim)"
# export LESS_TERMCAP_ZN="$(tput ssubm)"
# export LESS_TERMCAP_ZV="$(tput rsubm)"
# export LESS_TERMCAP_ZO="$(tput ssupm)"
# export LESS_TERMCAP_ZW="$(tput rsupm)"

export LIBVIRT_DEFAULT_URI=qemu:///system

# Needs installing x11-ssh-askpass
# TODO: fix keyboard layout issue
if [ -n "$SSH_ASKPASS" ] && test -x "$(command -v keychain)"; then
   eval "$(keychain --eval --agents ssh -Q --quiet id_rsa id_rsa_git)"
fi

[ -r "$HOME"/.dir_colors ] && eval "$(dircolors "$HOME"/.dir_colors)"

# Business specific or system dependant stuff
[ -r "$HOME"/.bash_profile_after ] && . "$HOME"/.bash_profile_after

[ -r "$HOME"/.bashrc ] && . "$HOME"/.bashrc
