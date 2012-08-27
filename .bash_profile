# todo: clear
# todo: move to .bashrc?
[[ -t 1 ]] && hash fortune >/dev/null 2>&1 && fortune

# file default 666 (-rw-rw-rw-) => 640 (-rw-r-----)
# directory default 777 (drwxrwxrwx) => 750 (drwxr-x---)
umask 027

if   command -v vimx >/dev/null 2>&1
then my_vim='vimx -v'
elif command -v gvim >/dev/null 2>&1
then my_vim='gvim -v'
else my_vim=vim
fi

export EDITOR=$my_vim
export VISUAL=$my_vim

# -i ignore case, -M ruler, -F quit if 1 screen, -PM long prompt
# ?test ok:else:else. The . ends the test
export LESS='-r -i -M -F -PM?f%f - :.?L%L lines, :.?ltL\:%lt:.?pB, %pB\% : .?e(Bottom)%t'

export    SHELL=/bin/bash
export  FIGNORE='~' # Completion
export HOSTFILE=$HOME/.hosts

shopt -s histappend

export       HISTFILE=$HOME/.bash_history
export   HISTFILESIZE=3000
export       HISTSIZE=3000 # size allowed in memory
export    HISTCONTROL=ignorespace:ignoredups:erasedups
export     HISTIGNORE="@(?|??|???|????)*( |$'\t'):*( |$'\t')"
# export   HISTIGNORE='@(?|??|???|????)*([[:space:]]):*([[:space:]])'
export HISTTIMEFORMAT='<%d %b %H:%M>  '

export   PATH=$PATH:$HOME/bin
export CDPATH=$HOME:..:../..

# todo: LANGUAGE ?
export       LANG=en_GB.UTF-8
export LC_COLLATE=C

LightGreen=$(tput bold; tput setaf 2)
 LightBlue=$(tput bold; tput setaf 4)
     Reset=$(tput sgr0)

# tput smso -> sm so -> set mode stand out (bold)
#      smul -> sm ul -> set mode underline
#      rmso -> rm so -> remove mode stand out...

export LESS_TERMCAP_mb=$LightGreen # begin blinking
export LESS_TERMCAP_md=$LightBlue  # begin bold
export LESS_TERMCAP_me=$Reset      # end mode
export LESS_TERMCAP_so=$(tput bold; tput setaf 3; tput setab 4) # so -> stand out - info box
export LESS_TERMCAP_se=$(tput rmso; tput sgr0)                  # se -> stand out end
# export LESS_TERMCAP_so=$'\E[01;47;34m'
# export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_us=$(tput smul; tput bold; tput setaf 5) # us -> underline start
export LESS_TERMCAP_ue=$(tput rmul; tput sgr0)               # ue -> underline end

# export LESS_TERMCAP_mr=$(tput rev)
# export LESS_TERMCAP_mh=$(tput dim)
# export LESS_TERMCAP_ZN=$(tput ssubm)
# export LESS_TERMCAP_ZV=$(tput rsubm)
# export LESS_TERMCAP_ZO=$(tput ssupm)
# export LESS_TERMCAP_ZW=$(tput rsupm)

[[ -r $HOME/.bashrc ]] && . "$HOME"/.bashrc

# Business specific or system dependant stuff
[[ -r $HOME/.bash_profile_after ]] && . "$HOME"/.bash_profile_after
