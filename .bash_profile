clear
hash fortune >/dev/null 2>&1 && fortune

# If vimx is found in $PATH, store it in the hash...
if command -v vimx >/dev/null 2>&1; then

    export MY_VIM=vimx
else
    export MY_VIM='gvim -v'
fi

export EDITOR="$MY_VIM"
export VISUAL="$MY_VIM"

# -i ignore case, -M ruler, -F quit if 1 screen, -PM long prompt
# ?test ok:else:else. The . ends the test
export LESS='-i -M -F -PM?f%f - :.?L%L lines, :.?ltL\:%lt:.?pB, %pB\% : .?e(Bottom)%t'

export FIGNORE='~'

export HISTFILE="$HOME"/.bash_history
export HISTSIZE=1000
export HISTFILESIZE=1000
export HISTCONTROL='ignorespace:ignoredups:erasedups'
export HISTIGNORE='?:??:???:????:*( )'

export HOSTFILE="$HOME"/.hosts

export LC_TIME=bg_BG.utf8

export PATH="$PATH:$HOME/bin"
export CDPATH="$HOME":..:../..

# .bashrc exists and I can read it
[[ -r ~/.bashrc ]] && source ~/.bashrc

# Business specific or system dependant stuff
[[ -r ~/.bash_profile_after ]] && source ~/.bash_profile_after
