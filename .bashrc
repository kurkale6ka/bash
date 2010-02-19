# Vim
#my_vim=vimx
my_vim='gvim -v'
alias v="$my_vim"
alias vi="$my_vim"
alias vim="$my_vim"
alias view="$my_vim -R"
alias vimdiff="$my_vim -d"

# Commands
alias cd..='cd ..'
alias ..='cd ..'
alias cd-='cd -'
#alias -='cd -'

color='--color=auto'
alias l="ls -F $color"
alias l.="ls -Fd .[^.]* $color"
alias ls="ls -F $color"
alias ll="ls -lF $color"
alias la="ls -AF $color"
alias lv='ls|vi -'

alias h=history
alias du='du -h'
alias df='df -h'

alias g='grep --color'
alias grep='grep --color'

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

alias j='jobs -l'

alias which='type -a'

# Vars
CDPATH='~:..:../..:'
HISTIGNORE='&:..:bg:fg:df:du:g:h:j:l:la:ll:ls:lv:pwd:v' # regex?
