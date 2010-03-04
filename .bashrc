# Author: Dimitar Dimitrov: mitkofr@yahoo.fr, kurkale6ka
#
#    Vim: zR to unfold everything, then :help folding
# ------------------------------------------------------

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

# PS1 and title ~\~1
clear

title="\e]0;\D{%e %B %Y}, bash $BASH_VERSION on $TERM, [\u@\H]\a"

if (( 0 == UID )); then

    echo 'Hi root'
    PS1="$title\n$txt_red\D{%a} \A \w [!\! - %\j]\n# $txt_rst"
else
    echo 'Hi kurkale6ka'
    PS1="$title\n$txt_ylw\D{%a} \A $txt_pur\w $txt_red[!\! - %\j]$txt_rst\n\$ "
fi

# Functions ~\~1
_exit() {

    clear
    echo -e "${txt_red}Hasta la vista, baby${txt_rst}"
}
trap _exit EXIT

# Usage: t my_archive.tar.gz => my_archive/
extract() {

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

# Usage: h arg - 'help arg' if it is a builtin, 'man arg' otherwise
# If mixing both types, as in 'h [ cat', only 'h [' will show
h() {

    local t="$(type -at "$@")"

    if [[ "$t" == *builtin* || "$t" == *keyword* ]]; then

        if [[ "$*" == *[* && "$*" != *[[* || "$*" == *test* ]]; then

            # If I ask for [ or test, I want them both
            help [ test | $my_vim -
        else
            help "$@"
        fi
    else
        man  "$@"
    fi
}

# Usage: wc my_file => 124 lines, 578 words and 1654 characters
my_wc()
{
    counts=($(\wc -lwm "$1"))
    echo "${counts[0]} lines, ${counts[1]} words and ${counts[2]} characters"
}

# Usage: ? arg - show how arg would be interpreted
my_which() {

    type -a "$1"

    if [[ $(whereis "$1") != *: ]]; then

        whereis "$1"
    fi
}

# Usage: my_file.c.bak <=> my_file.c
sw() {

    local tmpfile=tmp.$$

    (( 2 != $# )) && echo 'swap: 2 arguments needed' && return 1
    [[ ! -e $1 ]] && echo "swap: $1 does not exist"  && return 1
    [[ ! -e $2 ]] && echo "swap: $2 does not exist"  && return 1

    mv -- "$1"       $tmpfile
    mv -- "$2"      "$1"
    mv --  $tmpfile "$2"
}

# Usage: x - toggle debugging on/off
x() {

    if [[ $- == *x* ]]; then

        echo 'debug off'
        set +o xtrace
    else
        echo 'debug on'
        set -o xtrace
    fi
}

# Usage: bak my_file.c => my_file.c.bak
bak() { mv -- "$1" "$1".bak; }

# Usage: cg arg - computes a completion list for arg (help complete)
cg () { compgen -A "$1" | column; }

# Usage: fr '*.swp' - remove all those files
fr() { find . -name "$1" -exec rm -i {} +; }

# Usage: s old new [optional cmd number/string in history] (help fc)
s() { fc -s "$1"="$2" "$3"; }

# Aliases ~\~1

# Vim ~\~2
#my_vim=vimx
my_vim='gvim -v'
alias       v="$my_vim"
alias      vi="$my_vim"
alias     vim="$my_vim"
alias    view="$my_vim -R"
alias      vd="$my_vim -d"
alias vimdiff="$my_vim -d"
alias      gv=gvim
alias     gvi=gvim

# List directory contents ~\~2
alias   l=ls
alias  ls='ls -F --color=auto --dereference-command-line-symlink-to-dir'
alias  ll='ls -hl'
alias  ld='ls -d'
alias lld='ls -dhl'
alias  l.='ls -d  .[^.]*'
alias ll.='ls -dhl .[^.]*'
alias  la='ls -A'
alias lla='ls -Ahl'
alias  lr='ls -R'
alias  lv="ls|$my_vim -"

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
alias     ?=my_which
alias which=my_which
alias     i=info
alias     m=man
alias    ap=apropos
alias    mw=makewhatis

# Misc ~\~2
alias  e=echo
alias  f='find . -iname $*'
alias  j='jobs -l'
alias  t=extract
alias  u=unset
alias  z=fg
alias ex=export
alias cm=chmod
alias ln='ln -s'
alias mn=mount
alias pf=printf
alias pw=pwd
alias se=set
alias so=source
alias to=touch
alias wc=my_wc

alias shutdown='shutdown -h now'

alias  p='ps -aux'
alias pg=pgrep

alias  k=kill
alias ka=killall
alias pk=pkill

alias  cal='cal -3'
alias date="date '+%A -%e %B %Y, %H:%M %Z'"

alias    g=grep
alias grep='grep -i --color'

alias less="$my_vim -"
alias more="$my_vim -"
alias mo=more

alias  a=alias
alias ag='alias|grep'
alias am="alias|$my_vim -"
alias ua=unalias

alias  b='bind -p'
alias bg='bind -p|grep'
alias bm="bind -p|$my_vim -"

alias  hi=history
alias  hm="history|$my_vim -"
alias hgg='history|grep' # because of mercurial

alias    n=nslookup
alias ping='ping -c3'

alias  c=cat
alias cn='cat -n'

alias     o='set -o'
alias  se-o='set -o'
alias set-o='set -o'
alias    no='set +o'
alias  se+o='set +o'
alias set+o='set +o'
alias   opt=shopt

alias df='df -h'
alias du='du -h'

alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'

# -p lets you create a path structure, ex: mkdir -p /a/b/c
alias mf=mkfifo
alias md='mkdir -p'
alias rd=rmdir

# Spelling typos ~\~2
alias      bka=bak
alias      cta=cat
alias      mna=man
alias      otp=opt
alias    shotp=shopt
alias      pdw=pwd
alias     bnid=bind
alias     ehco=echo
alias     hlep=help
alias     jbos=jobs
alias     klil=kill
alias     mroe=more
alias     pnig=ping
alias     tpye=type
alias    alais=alias
alias    wihch=which
alias   exprot=export
alias  histroy=history
alias  hsitory=history
alias snlookup=nslookup
# Vim
alias   vmi=vim
alias  gvmi=gvim
alias  veiw=view
alias gveiw=gview
# languages and tools
alias    akw=awk
alias    pph=php
alias    sde=sed
alias   gerp=grep
alias   prel=perl
alias   rbuy=ruby
alias pyhton=python
# ~/~2

# Vars ~\~1
export CDPATH="$HOME":/cygdrive/c:/cygdrive/d:..:../..:
export EDITOR=$my_vim
export GIT_PROXY_COMMAND="$HOME"/.ssh/proxy_cmd_for_github
# -i ignore case, -M ruler, -F quit if 1 screen, -PM long prompt
# ?test ok:else:else. The . ends the test
export LESS='-i -M -F -PM?f%f - :.?L%L lines, :.?ltL\:%lt:.?pB, %pB\% : .?e(Bottom)%t'
export HISTIGNORE='&:..:...:-:1:2:3:4:a:am:b:bm:cd:cd-:cd..:cal:i:h:help:hlep:hm:bg:fg:z:c:cat:cta:df:du:hi:hsitory:histroy:history:j:jobs:jbos:l:l.:la:ll:lr:ls:lv:ll.:lla:o:se-o:set-o:no:se+o:set+o:se:set:opt:otp:shopt:shotp:p:pw:pwd:pdw:v:vi:vim:vmi:gv:gvi:gvim:gvmi:x'

# Shell options ~\~1
shopt -s cdspell
shopt -s extglob

set -o notify # about terminated jobs

# Programmable completion ~\~1
complete -A alias          a alias alais unalias
complete -A binding        b bind bnid
complete -A command        ? which wihch type tpye
#complete -A builtin        builtin
complete -A enabled        builtin
complete -A export         printenv
complete -A function       function
complete -A hostname       rsh rcp telnet rlogin r ftp ping disk ssh
complete -A user           chage chfn finger groups mail passwd slay su userdel usermod w write
complete -A variable       export local readonly unset

complete -A helptopic      h help # Currently, same as builtins.
complete -A signal         k kill klil
complete -A job     -P '%' j z fg jobs disown
complete -A stopped -P '%' bg
complete -A setopt         set o se-o set-o no se+o set+o
complete -A shopt          shopt opt

complete -A directory      cd
complete -A directory      md mkdir rd rmdir

# eXclude what not(!) matched by the pattern
complete -f -o default -X '!*.@(zip|ZIP|z|Z|gz|GZ|bz2|BZ2)' extract t tar

complete -f -o default -X '!*.php' php    pph
complete -f -o default -X '!*.pl'  perl   prel
complete -f -o default -X '!*.py'  python pyhton
complete -f -o default -X '!*.rb'  ruby   rbuy

complete -W 'alias arrayvar binding builtin command directory disabled enabled
export file function group helptopic hostname job keyword running service
setopt shopt signal stopped user variable' cg compgen

# Source business specific...

complete -W '--noplugins check-update clean deplist erase grouperase groupinfo
groupinstall grouplist groupremove groupupdate info install list localinstall
localupdate makecache provides remove repolist resolvedep search shell update
upgrade whatprovides' yum
