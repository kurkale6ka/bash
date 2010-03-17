# Author: Dimitar Dimitrov: mitkofr@yahoo.fr, kurkale6ka
#
#    Vim: zR to unfold everything, then :help folding
# ------------------------------------------------------

# Colors: set[af|ab] (ANSI [fore|back]ground) ~\~1
# black=$(tput setaf 0)
    red=$(tput setaf 1)
# green=$(tput setaf 2)
 yellow=$(tput setaf 3)
#  blue=$(tput setaf 4)
magenta=$(tput setaf 5)
#  cyan=$(tput setaf 6)
# white=$(tput setaf 7)

#    bold=$(tput bold)
underline=$(tput smul)
    reset=$(tput sgr0)

# PS1 and title ~\~1
clear

title="\e]2;\D{%e %B %Y}, bash $BASH_VERSION on $TERM, [\u@\H]\a" # \e]2; TITLE \a

if (( 0 == UID )); then

    echo 'Hi root'
    PS1="$title\n\[$red\]\D{%a} \A \w [!\! - %\j]\n# \[$reset\]"
else
    echo 'Hi kurkale6ka'
    PS1="$title\n\[$yellow\]\D{%a} \A \[$magenta\]\w \[$red\][!\! - %\j]\[$reset\]\n\$ "
fi

# Functions ~\~1
_exit() {

    clear
    echo -e "${red}Hasta la vista, baby$reset"
}
trap _exit EXIT

# Usage: t my_archive.tar.gz => my_archive/
extract() {

    for arg in "$@"; do

        if [[ -f $arg ]]; then

            case "$arg" in

                *.tar.gz|*.tgz)   tar zxvf   "$arg" ;;
                *.tar.bz2|*.tbz2) tar jxvf   "$arg" ;;
                *.tar)            tar xvf    "$arg" ;;
                *.bz2)            bunzip2    "$arg" ;;
                *.gz)             gunzip     "$arg" ;;
                *.zip)            unzip      "$arg" ;;
                *.rar)            unrar x    "$arg" ;;
                *.Z)              uncompress "$arg" ;;
                *.7z)             7z x       "$arg" ;;

                *) warn "'$arg' cannot be extracted via extract" ;;
            esac
        else
            warn "'$arg' is not a valid file"
        fi

    done
}

# Usage: h arg - 'help arg' if it is a builtin, 'man arg' otherwise
# If mixing both types, as in 'h [ cat', only 'h [' will show
h() {

    local t="$(type -at "$@")"

    if [[ "$t" == *builtin* || "$t" == *keyword* ]]; then

        if [[ "$*" == *[* && "$*" != *[[* || "$*" == *test* ]]; then

            # If I ask for [ or test, I want them both
            help [ test | $MY_VIM -
        else
            help "$@"
        fi
    else
        man "$@"
    fi
}

# Usage: sw my_file.c [my_file.c~] - my_file.c <=> my_file.c~
# the second arg is optional if it is the same arg with a '~' appended to it
sw() {

    [[ ! -e $1 ]]            && warn "file '$1' does not exist" && return 1
    [[ 2 == $# && ! -e $2 ]] && warn "file '$2' does not exist" && return 1

    local tmpfile=tmp.$$

    if (( 2 == $# )); then

        mv -- "$1"       $tmpfile
        mv -- "$2"      "$1"
        mv --  $tmpfile "$2"
    else
        mv -- "$1"       $tmpfile
        mv -- "$1"~     "$1"
        mv --  $tmpfile "$1"~
    fi
}

# Usage: wc my_file => 124 lines, 578 words and 1654 characters
wc() {

    for arg in "$@"; do

        local counts=($(command wc -lwm "$arg"))
        echo "${counts[0]} lines, ${counts[1]} words and ${counts[2]} characters"

    done
}

# Usage: ? arg - show how arg would be interpreted
_which() {

    for arg in "$@"; do

        type -a "$arg"

        if [[ $(whereis "$arg") != *: ]]; then

            whereis "$arg"
        fi

        (( i++ ))
        [[ $# > 1 && $i != $# ]] && echo

    done
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

# Usage: fr '*~' - remove all those files
fr() {

    if (( 0 == $# )); then

        warn "Usage: $FUNCNAME '*~'"
    else
        find . -name "$1" -exec rm -i {} +
    fi
}

# Usage: bak my_file.c => my_file.c~
bak() { for arg; do cp -- "$arg" "$arg"~; done; }

# Usage: cl arg - computes a completion list for arg (pb with cl job!)
cl() { compgen -A "$1" | column; }

# Usage: s old new [optional cmd number/string in history]
s() { fc -s "$1"="$2" "$3"; }

# Usage: warn 'message' - print a message to stderr
warn() { echo "$@" >&2; }

# Aliases ~\~1

# Vim ~\~2
#export MY_VIM=vimx
export MY_VIM='gvim -v'
alias       v="$MY_VIM"
alias      vi="$MY_VIM"
alias     vim="$MY_VIM"
alias    view="$MY_VIM -R"
alias      vd="$MY_VIM -d"
alias vimdiff="$MY_VIM -d"
alias      gv=gvim
alias     gvi=gvim

# List directory contents ~\~2
alias   l=ls
alias  ls='ls -FB --color=auto --dereference-command-line-symlink-to-dir'
alias  ll='ls -hl --time-style="+(%d/%m/%Y - %H:%M)"'
alias  ld='ls -d'
alias lld='ls -dhl --time-style="+(%d/%m/%Y - %H:%M)"'
alias  l.='ls -d .[^.]*'
alias ll.='ls -dhl --time-style="+(%d/%m/%Y - %H:%M)" .[^.]*'
alias  la='ls -A'
alias lla='ls -Ahl --time-style="+(%d/%m/%Y - %H:%M)"'
alias  lr='ls -R'
alias llr='ls -Rhl --time-style="+(%d/%m/%Y - %H:%M)"'
alias  lk='ls -S'
alias llk='ls -Shl --time-style="+(%d/%m/%Y - %H:%M)"'
alias  lx='ls -X'
alias llx='ls -Xhl --time-style="+(%d/%m/%Y - %H:%M)"'
alias  lv="ls|$MY_VIM -"

lc() { echo -e "$magenta${underline}Sorted by change date:$reset "; ls -tc; }
lm() { echo -e "$magenta${underline}Sorted by modification date:$reset "; ls -t; }
lu() { echo -e "$magenta${underline}Sorted by access date:$reset "; ls -tu; }

llc() {

    echo -en "$magenta${underline}Sorted by change date:$reset "
    ls -tchl --time-style='+(%d/%m/%Y - %H:%M)'
}

llm() {

    echo -en "$magenta${underline}Sorted by modification date:$reset "
    ls -thl --time-style='+(%d/%m/%Y - %H:%M)'
}

llu() {

    echo -en "$magenta${underline}Sorted by access date:$reset "
    ls -tuhl --time-style='+(%d/%m/%Y - %H:%M)'
}

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
alias which=_which
alias     ?=_which
alias     i=info
alias     m=man
alias    ap=apropos
alias    mw=makewhatis

# Misc ~\~2
alias     e=echo
alias     f='find . -iname "$@"'
alias     j='jobs -l'
alias     t=extract
alias     z=fg
alias    ej=eject
alias    en=enable
alias    ex=export
alias    ln='ln -s'
alias    pf=printf
alias    pw=pwd
alias    so=source
alias  env-='env -i'
alias    to=touch
alias   cmd=command
alias   msg=dmsg
alias  whoi=whoami
alias uname='uname -a' # function? os() - print all sys info...

alias pl=perl
alias py=python
alias rb=ruby

alias ag='alias|grep'
alias am="alias|$MY_VIM -"
alias  a=alias
alias ua=unalias

alias se=set
alias  u=unset

alias  mn=mount
alias umn=umount

alias cg=chgrp
alias cm=chmod
alias cx='chmod u+x'
alias co=chown
alias cr=chroot

alias shutdown='shutdown -h now'

alias ps='ps -ef'
alias pg=pgrep

alias  k=kill
alias ka=killall
alias pk=pkill

alias  cal='cal -3'
alias call='cal -y'
alias date="date '+%d %B %Y, %H:%M %Z (%A)'"

alias    g=grep
alias grep='grep -iE --color' # E for ERE

alias less="$MY_VIM -"
alias more="$MY_VIM -"
alias mo=more

alias   b='bind -p'
alias bgg='bind -p|grep'
alias  bm="bind -p|$MY_VIM -"

alias  hi=history
alias  hm="history|$MY_VIM -"
alias hgg='history|grep' # because of mercurial

alias d=dig
alias n=nslookup
alias p='ping -c3'

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
alias      akw=awk
alias    alais=alias
alias      bka=bak
alias     bnid=bind
alias      cdm=cmd
alias      cta=cat
alias     ehco=echo
alias   exprot=export
alias     gerp=grep
alias    gveiw=gview
alias     gvmi=gvim
alias  histroy=history
alias     hlep=help
alias  hsitory=history
alias     jbos=jobs
alias     klil=kill
alias      mna=man
alias     mroe=more
alias      otp=opt
alias      pdw=pwd
alias     pnig=ping
alias      pph=php
alias     prel=perl
alias   pyhton=python
alias     rbuy=ruby
alias      sde=sed
alias    shotp=shopt
alias snlookup=nslookup
alias     tpye=type
alias     veiw=view
alias      vmi=vim
alias    wihch=_which
# ~/~2

# Vars ~\~1
export CDPATH="$HOME":/cygdrive/c:/cygdrive/d:..:../..:
export EDITOR=$MY_VIM
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

# eXclude what is not(!) matched by the pattern
complete -f -o default -X '!*.@(zip|ZIP|z|Z|gz|GZ|bz2|BZ2)' extract t tar

complete -f -o default -X '!*.php' php    pph
complete -f -o default -X '!*.pl'  perl   prel   pl
complete -f -o default -X '!*.py'  python pyhton py
complete -f -o default -X '!*.rb'  ruby   rbuy   rb

#longopts() {
#
#    COMP_WORDBREAKS=${COMP_WORDBREAKS/=/}
#
#    local cur=${COMP_WORDS[COMP_CWORD]}
#
#    [[ ! $cur ]] && return
#
#    COMPREPLY=($(
#
#    "$1" --help    | grep -oe '--[[:alpha:]][[:alpha:]-]+\[?=?([[:alpha:]-]|_)+\]?' |
#    grep -e "$cur" | sort -u
#
#    ))
#
#    for reply in "${COMPREPLY[@]}"; do
#
#        if [[ $reply == *[* ]]; then
#
#            reply=${reply%]}
#        fi
#    done
#}
#
#complete -o default -F longopts ls git

complete -W 'alias arrayvar binding builtin command directory disabled enabled
export file function group helptopic hostname job keyword running service
setopt shopt signal stopped user variable' cl compgen

# Source business specific...

complete -W '--noplugins check-update clean deplist erase grouperase groupinfo
groupinstall grouplist groupremove groupupdate info install list localinstall
localupdate makecache provides remove repolist resolvedep search shell update
upgrade whatprovides' yum
