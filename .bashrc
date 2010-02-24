# Colors ~\~1
txt_blk='\e[0;30m' # Black - Regular
txt_blu='\e[0;34m' # Blue
txt_cyn='\e[0;36m' # Cyan
txt_grn='\e[0;32m' # Green
txt_pur='\e[0;35m' # Purple
txt_red='\e[0;31m' # Red
txt_wht='\e[0;37m' # White
txt_ylw='\e[0;33m' # Yellow
#--------------------------------------
bld_blk='\e[1;30m' # Black - Bold
bld_blu='\e[1;34m' # Blue
bld_cyn='\e[1;36m' # Cyan
bld_grn='\e[1;32m' # Green
bld_pur='\e[1;35m' # Purple
bld_red='\e[1;31m' # Red
bld_wht='\e[1;37m' # White
bld_ylw='\e[1;33m' # Yellow
#--------------------------------------
und_blk='\e[4;30m' # Black - Underline
und_blu='\e[4;34m' # Blue
und_cyn='\e[4;36m' # Cyan
und_grn='\e[4;32m' # Green
und_pur='\e[4;35m' # Purple
und_red='\e[4;31m' # Red
und_wht='\e[4;37m' # White
und_ylw='\e[4;33m' # Yellow
#--------------------------------------
bak_blk='\e[40m'   # Black - Background
bak_blu='\e[44m'   # Blue
bak_cyn='\e[46m'   # Cyan
bak_grn='\e[42m'   # Green
bak_pur='\e[45m'   # Purple
bak_red='\e[41m'   # Red
bak_wht='\e[47m'   # White
bak_ylw='\e[43m'   # Yellow
#--------------------------------------
txt_rst='\e[0m'    # Text Reset

# PS1 + title ~\~1
clear

title="\e]0;\D{%e %B %Y}, bash $BASH_VERSION on $TERM, [\u@\H]\a"

if (( 0 == $UID )); then

    echo 'Hi root'
    PS1="$title\n$txt_red\D{%a} \A \w [!\! - %\j]\n# $txt_rst"
else
    echo 'Hi kurkale6ka'
    PS1="$title\n$txt_ylw\D{%a} \A $txt_pur\w $txt_red[!\! - %\j]$txt_rst\n\$ "
fi

# Functions: bak, exit, extract, swap, wc, x ~\~1
function _exit()
{
    clear
    echo -e "${txt_red}Hasta la vista, baby${txt_rst}"
}
trap _exit EXIT

function extract()
{
    if [[ -f $1 ]]
    then
        case "$1" in
            *.tar.gz|*.tgz)   tar zxvf   "$1" ;;
            *.tar.bz2|*.tbz2) tar jxvf   "$1" ;;
            *.tar)            tar xvf    "$1" ;;
            *.bz2)            bunzip2    "$1" ;;
            *.gz)             gunzip     "$1" ;;
            *.zip)            unzip      "$1" ;;
            *.rar)            unrar x    "$1" ;;
            *.Z)              uncompress "$1" ;;
            *.7z)             7z x       "$1" ;;
            *)                echo "'$1' cannot be extracted via extract" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

function bak()
{
    mv "$1" "$1".bak
}

function my_wc()
{
    for file in "$@"; do

        counts=($(\wc -lwm "$file"))
        echo "${counts[0]} lines, ${counts[1]} words and ${counts[2]} characters: ${counts[3]}"
    done
}

function x()
{
    if [[ $- == *x* ]]; then

        echo 'debug off'
        set +o xtrace
    else
        echo 'debug on'
        set -o xtrace
    fi
}

function swap()
{
    local tmpfile=tmp.$$

    (( 2 != $# )) && echo "swap: 2 arguments needed" && return 1
    [[ ! -e $1 ]] && echo "swap: $1 does not exist"  && return 1
    [[ ! -e $2 ]] && echo "swap: $2 does not exist"  && return 1

    mv "$1"       $tmpfile
    mv "$2"      "$1"
    mv  $tmpfile "$2"
}

# Aliases ~\~1

# Vim ~\~2
#my_vim=vimx
my_vim='gvim -v'
alias       v="$my_vim"
alias      vi="$my_vim"
alias     vim="$my_vim"
alias    view="$my_vim -R"
alias vimdiff="$my_vim -d"
alias      gv=gvim
alias     gvi=gvim

# List directory contents ~\~2
alias   l=ls
alias  ls='ls -F --color=auto --dereference-command-line-symlink-to-dir'
alias  ll='ls -l'
alias  l.='ls -d  .[^.]*'
alias ll.='ls -dl .[^.]*'
alias  la='ls -A'
alias lla='ls -Al'
alias  lr='ls -R'
alias  lv='ls|vi -'

# Change directory ~\~2
alias  cd-='cd -'
alias -- -='cd -'
alias    1='cd ..'
alias    2='cd ../..'
alias    3='cd ../../..'
alias    4='cd ../../../..'
alias cd..='cd ..'
alias   ..='cd ..'
alias  ...='cd ../..'

# Help ~\~2
alias b=help # builtin
alias i=info
alias m=man

# Misc ~\~2
alias  .=pwd
alias  a=awk
alias  e=echo
alias  f='find . -name $*'
alias  h=history
alias  j='jobs -l'
alias  k=kill
alias  p='ps -aux'
alias  t=extract
alias  z=fg
alias so=source
alias wc=my_wc

alias   c=cat
alias cat='cat -n'

alias less='vi -'
alias more='vi -'

alias     o='set -o'
alias set-o='set -o'

alias     ?='type -a'
alias which='type -a'

alias df='df -h'
alias du='du -h'

alias    g=grep
alias grep='grep --color'

alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'

# -p lets you create a path structure, ex: mkdir -p /a/b/c
alias md='mkdir -p'
alias rd=rmdir

# Spelling typos ~\~2
alias   alais=alias
alias    bnid=bind
alias     cta=cat
alias    ehco=echo
alias  exprot=export
alias hsitory=history
alias histroy=history
alias    hlep=help
alias    jbos=jobs
alias     mna=man
alias    mroe=more
alias     pdw=pwd
alias    gerp=grep
alias    klil=kill
alias   gveiw=gview
alias    gvmi=gvim
alias    veiw=view
alias     vmi=vim
alias     akw=awk
alias     sde=sed
alias    prel=perl
alias  pyhton=python
alias    rbuy=ruby
alias     pph=php
alias     bka=bak
alias    sawp=swap
# ~/~2

# Vars ~\~1
export CDPATH='~:..:../..:'
export EDITOR=$my_vim
export GIT_PROXY_COMMAND=~/.ssh/proxy_cmd_for_github
export HISTIGNORE='&:.:..:...:-:1:2:3:4:cd:cd-:cd..:b:help:hlep:i:[bf]g:z:c:cat:cta:d[fu]:h:hsitory:histroy:history:j:jobs:jbos:l:l[.alrsv]:ll[.a]:o:set-o:p:pwd:pdw:v:vi:vim:vmi:gv:gvi:gvim:gvmi:x'

# Shell options ~\~1
shopt -s cdspell
shopt -s extglob

set -o notify # about terminated jobs

# Programmable completion ~\~1
complete -A hostname rsh rcp telnet rlogin r ftp ping disk ssh
complete -A export   printenv
complete -A variable export local readonly unset
complete -A enabled  builtin
complete -A alias    alias unalias
complete -A function function
complete -A user     su mail finger

complete -A helptopic      help # Currently, same as builtins.
complete -A shopt          shopt
complete -A stopped -P '%' bg
complete -A job -P '%'     fg z j jobs disown

complete -A directory            md mkdir rd rmdir
complete -A directory -o default cd

# Compression
complete -f -o default -X '!*.+(zip|ZIP|z|Z|gz|GZ|bz2|BZ2)' extract t tar

complete -f -o default -X '!*.pl'  perl
complete -f -o default -X '!*.php' php
complete -f -o default -X '!*.py'  python
complete -f -o default -X '!*.rb'  ruby
