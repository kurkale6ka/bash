txt_blk='\e[0;30m' # Black - Regular
txt_red='\e[0;31m' # Red
txt_grn='\e[0;32m' # Green
txt_ylw='\e[0;33m' # Yellow
txt_blu='\e[0;34m' # Blue
txt_pur='\e[0;35m' # Purple
txt_cyn='\e[0;36m' # Cyan
txt_wht='\e[0;37m' # White
bld_blk='\e[1;30m' # Black - Bold
bld_red='\e[1;31m' # Red
bld_grn='\e[1;32m' # Green
bld_ylw='\e[1;33m' # Yellow
bld_blu='\e[1;34m' # Blue
bld_pur='\e[1;35m' # Purple
bld_cyn='\e[1;36m' # Cyan
bld_wht='\e[1;37m' # White
und_blk='\e[4;30m' # Black - Underline
und_red='\e[4;31m' # Red
und_grn='\e[4;32m' # Green
und_ylw='\e[4;33m' # Yellow
und_blu='\e[4;34m' # Blue
und_pur='\e[4;35m' # Purple
und_cyn='\e[4;36m' # Cyan
und_wht='\e[4;37m' # White
bak_blk='\e[40m'   # Black - Background
bak_red='\e[41m'   # Red
bak_grn='\e[42m'   # Green
bak_ylw='\e[43m'   # Yellow
bak_blu='\e[44m'   # Blue
bak_pur='\e[45m'   # Purple
bak_cyn='\e[46m'   # Cyan
bak_wht='\e[47m'   # White
txt_rst='\e[0m'    # Text Reset

PS1="$txt_ylw\D{%a} \A $txt_blu[\j] $txt_grn\w$txt_rst\n\$"

# Vim
#my_vim=vimx
my_vim='gvim -v'
alias       v="$my_vim"
alias      vi="$my_vim"
alias     vim="$my_vim"
alias    view="$my_vim -R"
alias vimdiff="$my_vim -d"

# Change/print directory
alias    .='pwd'
alias  cd-='cd -'
alias -- -='cd -'
alias cd..='cd ..'
alias   ..='cd ..'
alias  ...='cd ../..'

# "-p" lets you create a path structure with one command, ex. mkdir -p /a/b/c
alias md='mkdir -p'
alias rd='rmdir'

# Misc
alias e=echo
#alias e$='echo $'
alias h=history
alias j='jobs -l'
alias m=man
alias t='tar -zxvf'
alias f='find . -name $*'

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
