clear
hash fortune >/dev/null 2>&1 && fortune

# Checks that vimx is installed
if command -v vimx >/dev/null 2>&1; then
   my_vim='vimx -v'
elif command -v gvim >/dev/null 2>&1; then
   my_vim='gvim -v'
else
   my_vim=vi
fi

export EDITOR="$my_vim"
export VISUAL="$my_vim"

# -i ignore case, -M ruler, -F quit if 1 screen, -PM long prompt
# ?test ok:else:else. The . ends the test
export LESS='-r -i -M -F -PM?f%f - :.?L%L lines, :.?ltL\:%lt:.?pB, %pB\% : .?e(Bottom)%t'
# export LESS_TERMCAP_mb=$'\E[01;31m'
# export LESS_TERMCAP_md=$'\E[01;31m'
# export LESS_TERMCAP_me=$'\E[0m'
# export LESS_TERMCAP_se=$'\E[0m'
# export LESS_TERMCAP_so=$'\E[01;47;34m'
# export LESS_TERMCAP_ue=$'\E[0m'
# export LESS_TERMCAP_us=$'\E[01;32m'

export LESS_TERMCAP_mb=$'\E[01;31m'       # begin blinking
export LESS_TERMCAP_md=$'\E[01;38;5;74m'  # begin bold
export LESS_TERMCAP_me=$'\E[0m'           # end mode
# export LESS_TERMCAP_se=$'\E[0m'           # end standout-mode
# export LESS_TERMCAP_so=$'\E[38;5;246m'    # begin standout-mode - info box
export LESS_TERMCAP_so=$(tput bold; tput setaf 3; tput setab 4) # yellow on blue
export LESS_TERMCAP_se=$(tput rmso; tput sgr0)
export LESS_TERMCAP_us=$'\E[04;38;5;146m' # begin underline
export LESS_TERMCAP_ue=$'\E[0m'           # end underline

# export LESS_TERMCAP_mb=$(tput bold; tput setaf 2) # green
# export LESS_TERMCAP_md=$(tput bold; tput setaf 6) # cyan
# export LESS_TERMCAP_me=$(tput sgr0)
# export LESS_TERMCAP_so=$(tput bold; tput setaf 3; tput setab 4) # yellow on blue
# export LESS_TERMCAP_se=$(tput rmso; tput sgr0)
# export LESS_TERMCAP_us=$(tput smul; tput bold; tput setaf 7) # white
# export LESS_TERMCAP_ue=$(tput rmul; tput sgr0)
# export LESS_TERMCAP_mr=$(tput rev)
# export LESS_TERMCAP_mh=$(tput dim)
# export LESS_TERMCAP_ZN=$(tput ssubm)
# export LESS_TERMCAP_ZV=$(tput rsubm)
# export LESS_TERMCAP_ZO=$(tput ssupm)
# export LESS_TERMCAP_ZW=$(tput rsupm)

# Completion
export FIGNORE='~'
export HOSTFILE="$HOME"/.hosts

export HISTFILE="$HOME"/.bash_history
export HISTSIZE=1000
export HISTFILESIZE=1000
export HISTCONTROL='ignorespace:ignoredups:erasedups'
# export HISTIGNORE='@(?|??|???|????)*([[:space:]]):*([[:space:]])'
export HISTIGNORE="@(?|??|???|????)*( |$'\t'):*( |$'\t')"

export PATH="$PATH:$HOME/bin"
export CDPATH="$HOME":..:../..

export LANG='en_GB.UTF-8'
export LC_COLLATE='C'

# file default 666 (-rw-rw-rw-) => 640 (-rw-r-----)
# directory default 777 (drwxrwxrwx) => 750 (drwxr-x---)
umask 027

# .bashrc exists and I can read it
[[ -r ~/.bashrc ]] && source ~/.bashrc

# Business specific or system dependant stuff
[[ -r ~/.bash_profile_after ]] && source ~/.bash_profile_after
