# todo: clear
# todo: move to .bashrc?
[[ -t 1 ]] && hash fortune >/dev/null 2>&1 && fortune

# file default 666 (-rw-rw-rw-) => 640 (-rw-r--r--)
# directory default 777 (drwxrwxrwx) => 750 (drwxr-xr-x)
umask 022

export EDITOR="command vim -u $HOME/.vimrc"
export VISUAL="command vim -u $HOME/.vimrc"
export MYVIMRC="$HOME"/.vimrc
export MYGVIMRC="$HOME"/.gvimrc

# -i ignore case, -M ruler, -F quit if 1 screen, -PM long prompt
# ?test--true--:--false--. The dot ends the test
export LESS='-r -i -M -F -PM?f%f - :.?L%L lines, :.?ltL\:%lt:.?pB, %pB\% : .?e(Bottom)%t'

export    SHELL=/bin/bash
# <tab> completion.
#  ls: ls -B to ignore backup files (~) in listings
# Vim: set wildignore+=*~,*.swp
export  FIGNORE='~:.swp:.o'
export HOSTFILE=$HOME/.hosts

shopt -s histappend

export       HISTFILE=$HOME/.bash_history
export   HISTFILESIZE=11000
export       HISTSIZE=11000 # size allowed in memory
export    HISTCONTROL=ignorespace:ignoredups:erasedups
export     HISTIGNORE="@(?|??|???|????)*( |$'\t'):*( |$'\t')"
# export   HISTIGNORE='@(?|??|???|????)*([[:space:]]):*([[:space:]])'
export HISTTIMEFORMAT='<%d %b %H:%M>  '

export   PATH=$PATH:$HOME/bin
export CDPATH=$HOME:..:../..

# todo: LANGUAGE ?
export       LANG=en_GB.UTF-8
export LC_COLLATE=C

export LIBVIRT_DEFAULT_URI=qemu:///system

[[ -r $HOME/.dir_colors ]] && eval "$(dircolors $HOME/.dir_colors)"

[[ -r $HOME/.bashrc ]] && . "$HOME"/.bashrc

# Business specific or system dependant stuff
[[ -r $HOME/.bash_profile_after ]] && . "$HOME"/.bash_profile_after
