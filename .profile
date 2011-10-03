clear
hash fortune >/dev/null 2>&1 && fortune

# Checks that vimx is installed
if command -v vimx >/dev/null 2>&1; then

    export MY_GVIM=vimx
else
    export MY_GVIM=gvim
fi
export MY_VIM="$MY_GVIM -v"

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
# export HISTIGNORE='@(?|??|???|????)*([[:space:]]):*([[:space:]])'
export HISTIGNORE="@(?|??|???|????)*( |$'\t'):*( |$'\t')"

export HOSTFILE="$HOME"/.hosts

export LC_TIME=bg_BG.utf8

export PATH="$PATH:$HOME/bin"
export CDPATH="$HOME":..:../..

umask 027

# .bashrc exists and I can read it
[[ -r ~/.bashrc ]] && source ~/.bashrc

# Business specific or system dependant stuff
[[ -r ~/.bash_profile_after ]] && source ~/.bash_profile_after
