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

# Motd
#echo -e "${txt_cyn}bash ${txt_red}${BASH_VERSION%.*}$txt_rst\n"
#echo    'A song of Ice and Fire'
##date +"%e %B %Y"
#
#function _exit()
#{
#    echo -e "${txt_red}Hasta la vista, baby${txt_rst}"
#}
#trap _exit EXIT

title="\e]0;[$TERM - \u@\h] \w\a"
PS1="$title\n$txt_ylw\D{%a} \A $txt_pur\w $txt_red[!\! - %\j]$txt_rst\n\$"

function extract()
{
    if [ -f $1 ]
    then
        case $1 in
            *.tar.gz|*.tgz)   tar zxvf   $1 ;;
            *.tar.bz2|*.tbz2) tar jxvf   $1 ;;
            *.tar)            tar xvf    $1 ;;
            *.bz2)            bunzip2    $1 ;;
            *.gz)             gunzip     $1 ;;
            *.zip)            unzip      $1 ;;
            *.rar)            unrar x    $1 ;;
            *.Z)              uncompress $1 ;;
            *.7z)             7z x       $1 ;;
            *)                echo "'$1' cannot be extracted via extract" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

function bak()
{
    mv $1 $1.bak
}

function swap()
{
    local tmpfile=tmp.$$ 

    [ $# -ne 2 ] && echo "swap: 2 arguments needed" && return 1
    [ !  -e $1 ] && echo "swap: $1 does not exist"  && return 1
    [ !  -e $2 ] && echo "swap: $2 does not exist"  && return 1

    mv "$1" $tmpfile 
    mv "$2" "$1"
    mv $tmpfile "$2"
}

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
#alias    /='cd /'
#alias  cd/='cd /'
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
alias f='find . -name $*'
alias t=extract

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

alias so=source

alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'

shopt -s cdspell

# Vars
export CDPATH='~:..:../..:'
export EDITOR=$my_vim
export HISTIGNORE='&:.:..:...:-:[bf]g:cd-:cd..:d[fu]:h:j:l:l.:la:ll:lr:ls:lv:pwd:v:vi:vim:gvim'

shopt -s extglob # Necessary,
#set +o nounset  # otherwise some completions will fail.

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
complete -A job -P '%'     fg jobs disown

complete -A directory            mkdir rmdir
complete -A directory -o default cd

# Compression
complete -f -o default -X '!*.+(zip|ZIP|z|Z|gz|GZ|bz2|BZ2)' extract

complete -f -o default -X '!*.pl' perl
complete -f -o default -X '!*.py' python
complete -f -o default -X '!*.rb' ruby
