# todo: clear
# todo: move to .bashrc?
[[ -t 1 ]] && hash fortune >/dev/null 2>&1 && fortune

# file default 666 (-rw-rw-rw-) => 640 (-rw-r--r--)
# directory default 777 (drwxrwxrwx) => 750 (drwxr-xr-x)
umask 022

if   command -v vimx; then
   my_vim='vimx -v'
elif command -v gvim; then
   my_vim='gvim -v'
else
   my_vim=vim
fi >/dev/null 2>&1

export EDITOR=$my_vim
export VISUAL=$my_vim

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
export   HISTFILESIZE=3000
export       HISTSIZE=1000 # size allowed in memory
export    HISTCONTROL=ignorespace:ignoredups:erasedups
export     HISTIGNORE="@(?|??|???|????)*( |$'\t'):*( |$'\t')"
# export   HISTIGNORE='@(?|??|???|????)*([[:space:]]):*([[:space:]])'
export HISTTIMEFORMAT='<%d %b %H:%M>  '

export   PATH=$PATH:$HOME/bin
export CDPATH=$HOME:..:../..

# todo: LANGUAGE ?
export       LANG=en_GB.UTF-8
export LC_COLLATE=C

      Bold=$(tput bold)
 Underline=$(tput smul)
     Reset=$(tput sgr0)
LightGreen=$(printf %s "$Bold"; tput setaf 2)
 LightBlue=$(printf %s "$Bold"; tput setaf 4)

# tput smso -> sm so -> set mode stand out (bold)
#      smul -> sm ul -> set mode underline
#      rmso -> rm so -> remove mode stand out...

export LESS_TERMCAP_mb=$LightGreen # begin blinking
export LESS_TERMCAP_md=$LightBlue  # begin bold
export LESS_TERMCAP_me=$Reset      # end mode
# so -> stand out - info box
export LESS_TERMCAP_so=$(printf %s "$Bold"; tput setaf 3; tput setab 4)
# se -> stand out end
export LESS_TERMCAP_se=$(tput rmso; printf %s "$Reset")
# export LESS_TERMCAP_so=$'\E[01;47;34m'
# export LESS_TERMCAP_se=$'\E[0m'
# us -> underline start
export LESS_TERMCAP_us=$(printf %s%s "$Bold$Underline"; tput setaf 5)
# ue -> underline end
export LESS_TERMCAP_ue=$(tput rmul; printf %s "$Reset")

# export LESS_TERMCAP_mr=$(tput rev)
# export LESS_TERMCAP_mh=$(tput dim)
# export LESS_TERMCAP_ZN=$(tput ssubm)
# export LESS_TERMCAP_ZV=$(tput rsubm)
# export LESS_TERMCAP_ZO=$(tput ssupm)
# export LESS_TERMCAP_ZW=$(tput rsupm)

export LIBVIRT_DEFAULT_URI=qemu:///system

[[ -r $HOME/.bashrc ]] && . "$HOME"/.bashrc

# Business specific or system dependant stuff
[[ -r $HOME/.bash_profile_after ]] && . "$HOME"/.bash_profile_after
