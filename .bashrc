# Vim
#my_vim=vimx
my_vim='gvim -v'
alias       v="$my_vim"
alias      vi="$my_vim"
alias     vim="$my_vim"
alias    view="$my_vim -R"
alias vimdiff="$my_vim -d"

# Change/print directory
alias   -- .='pwd'
alias    cd-='cd -'
alias   -- -='cd -'
alias   cd..='cd ..'
alias  -- ..='cd ..'
alias -- ...='cd ../..'

# "-p" lets you create a path structure with one command, ex. mkdir -p /a/b/c
alias md='mkdir -p'
alias rd='rmdir'

# Misc
alias  h=history
alias  j='jobs -l'
alias  m=man
alias  t='tar -zxvf'
alias ff='find . -name $*'

# List directory
color='--color=auto'
alias  l="ls -F $color"
alias l.="ls -Fd .[^.]* $color"
alias la="ls -FA $color"
alias ll="ls -Fl $color"
alias lr="ls -FR $color"
alias ls="ls -F $color"
alias lv='ls|vi -'

alias df='df -h'
alias du='du -h'

alias    g='grep --color'
alias grep='grep --color'

alias     ?='type -a'
alias which='type -a'

alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'

# Vars
CDPATH='~:..:../..:'
HISTIGNORE='&:.:..:...:-:bg:cd-:cd..:fg:df:du:h:j:l:l.:la:ll:lr:ls:lv:pwd:v:vi:vim:gvim' # regex?
