# clear
hash fortune >/dev/null 2>&1 && fortune

# Checks that vimx is installed
if command -v vimx >/dev/null 2>&1; then
   my_vim='vimx -v'
elif command -v gvim >/dev/null 2>&1; then
   my_vim='gvim -v'
else
   my_vim=vim
fi

export EDITOR="$my_vim"
export VISUAL="$my_vim"

# Black="$(tput setaf 0)"
# BlackBG="$(tput setab 0)"
# DarkGrey="$(tput bold ; tput setaf 0)"
# LightGrey="$(tput setaf 7)"
# LightGreyBG="$(tput setab 7)"
# White="$(tput bold ; tput setaf 7)"
# Red="$(tput setaf 1)"
# RedBG="$(tput setab 1)"
  LightRed="$(tput bold ; tput setaf 1)"
# Green="$(tput setaf 2)"
# GreenBG="$(tput setab 2)"
  LightGreen="$(tput bold ; tput setaf 2)"
# Brown="$(tput setaf 3)"
# BrownBG="$(tput setab 3)"
# LightBrown="$(tput setaf 3)" bogus
# Yellow="$(tput bold ; tput setaf 3)"
# Blue="$(tput setaf 4)"
# BlueBG="$(tput setab 4)"
  LightBlue="$(tput bold ; tput setaf 4)"
  Purple="$(tput setaf 5)"
# PurpleBG="$(tput setab 5)"
# Pink="$(tput bold ; tput setaf 5)"
# Cyan="$(tput setaf 6)"
# CyanBG="$(tput setab 6)"
# LightCyan="$(tput bold ; tput setaf 6)"
# Bold="$(tput bold)"
  Underline="$(tput smul)"
  Reset="$(tput sgr0)" # No Color

# -i ignore case, -M ruler, -F quit if 1 screen, -PM long prompt
# ?test ok:else:else. The . ends the test
export LESS='-r -i -M -F -PM?f%f - :.?L%L lines, :.?ltL\:%lt:.?pB, %pB\% : .?e(Bottom)%t'

# tput smso -> sm so -> set mode stand out (bold)
#      smul -> sm ul -> set mode underline
#      rmso -> rm so -> remove mode stand out...

export LESS_TERMCAP_mb="$LightGreen" # begin blinking
export LESS_TERMCAP_md="$LightBlue"  # begin bold
export LESS_TERMCAP_me="$Reset"      # end mode
export LESS_TERMCAP_so="$(tput bold; tput setaf 3; tput setab 4)" # so -> stand out - info box
export LESS_TERMCAP_se="$(tput rmso; tput sgr0)"                  # se -> stand out end
# export LESS_TERMCAP_so=$'\E[01;47;34m'
# export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_us="$(tput smul; tput bold; tput setaf 5)" # us -> underline start
export LESS_TERMCAP_ue="$(tput rmul; tput sgr0)"               # ue -> underline end

# export LESS_TERMCAP_mr="$(tput rev)"
# export LESS_TERMCAP_mh="$(tput dim)"
# export LESS_TERMCAP_ZN="$(tput ssubm)"
# export LESS_TERMCAP_ZV="$(tput rsubm)"
# export LESS_TERMCAP_ZO="$(tput ssupm)"
# export LESS_TERMCAP_ZW="$(tput rsupm)"

# Completion
export FIGNORE='~'
export HOSTFILE="$HOME"/.hosts

export HISTFILE="$HOME"/.bash_history
export HISTSIZE=1000
export HISTFILESIZE=1000
export HISTCONTROL='ignorespace:ignoredups:erasedups'
# export HISTIGNORE='@(?|??|???|????)*([[:space:]]):*([[:space:]])'
export HISTIGNORE="@(?|??|???|????)*( |$'\t'):*( |$'\t')"
export HISTTIMEFORMAT='<%d %b %H:%M>  '

export PATH="$PATH:$HOME"/bin
export CDPATH="$HOME:..:../.."

export LANG=en_GB.UTF-8
export LC_COLLATE=C

export SHELL=/bin/bash

# file default 666 (-rw-rw-rw-) => 640 (-rw-r-----)
# directory default 777 (drwxrwxrwx) => 750 (drwxr-x---)
umask 027

# .bashrc exists and I can read it
[[ -r ~/.bashrc ]] && source ~/.bashrc

# Business specific or system dependant stuff
[[ -r ~/.bash_profile_after ]] && source ~/.bash_profile_after
