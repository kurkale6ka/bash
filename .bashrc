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

if [[ linux != $TERM ]]; then

    title="\e]2;\D{%e %B %Y (%A)}, bash $BASH_VERSION on $TERM\a" # \e]2; TITLE \a
fi

if (( 0 == UID )); then

    echo 'Hi root'
    PS1="$title\n\[$red\][\u@\H] \w (!\! - %\j, \A)\n# \[$reset\]"
else
    echo 'Hi kurkale6ka'
    PS1="$title\n\[$yellow\][\u@\H] \[$magenta\]\w \[$red\](!\! - %\j, \A)\[$reset\]\n\$ "
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

    if [[ 0 == $# ]]; then

        # Find all not dot files (count the number of dots printf prints)
        # Rem: I must also exclude those: ./.git/file (not a dot file!)
        find . -name '[!.]*' -exec printf '.' \; | command wc -c

    else

        for arg in "$@"; do

            local counts=($(command wc -lwm "$arg"))
            echo "${counts[0]} lines, ${counts[1]} words and ${counts[2]} characters"
        done
    fi
}

alias wcc="find . -exec printf '.' \; | command wc -c"
alias wc.="find . -name '.*' \! -name '.' -not -name '..' -exec printf '.' ';' | command wc -c"

# Usage: ? arg - show how arg would be interpreted
_which() {

    local i

    for arg in "$@"; do

        type -a "$arg"

        [[ $(whereis -b "$arg") != *: ]] && { echo Binaries:; whereis -b "$arg"; }
        [[ $(whereis -s "$arg") != *: ]] && { echo Sources:;  whereis -s "$arg"; }
        [[ $(whereis -m "$arg") != *: ]] && { echo Sections:; whereis -m "$arg"; }

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

# Usage: bak my_file1.c, my_file2.c => my_file1.c~, my_file2.c~
bak() { for arg in "$@"; do cp -- "$arg" "$arg"~; done; }

# Usage: cl arg - computes a completion list for arg
cl() { column <(compgen -A "$1"); }

# Usage: ee array1, array2 - prints arrays in columns
ee() {

    local i

    for arg in "$@"; do

        local arr="$arg[@]" # no {} ?

        printf "%s\n" "${!arr}" | column

        (( i++ ))
        [[ $# > 1 && $i != $# ]] && echo
    done
}

# Usage: s old new [optional cmd number/string in history]
s() { fc -s "$1"="$2" "$3"; }

# Usage: warn 'message' - print a message to stderr
warn() { echo "$@" >&2; }

# Aliases ~\~1

# Vim ~\~2
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

lc() { echo -e "$magenta${underline}Sorted by change date:$reset ";       ls -tc; }
lm() { echo -e "$magenta${underline}Sorted by modification date:$reset "; ls -t;  }
lu() { echo -e "$magenta${underline}Sorted by access date:$reset ";       ls -tu; }

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
alias     t=extract
alias     z=fg
alias    ej=eject
alias    ex=export
alias    ln='ln -s'
alias    pf=printf
alias    pp='(IFS=:; printf "%s\n" $PATH)'
alias    pw=pwd
alias    sc=screen
alias    so=source
alias    to=touch
alias    tp=tput
alias   cmd=command
alias   msg=dmesg
alias   sed='sed -r' # ERE (Extended regex)
alias  env-='env -i'
alias  whoi=whoami
alias uname='uname -a' # function? os() - print all sys info...

alias en=enable
alias di='enable -n'

alias     j='jobs -l'
alias -- --='fg %-'

alias gc='git commit -a'
alias gp='git push origin master'

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
alias grep='grep -iE --color' # ERE (Extended regex)

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
alias       pt=tput
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

# Shell options ~\~1
shopt -s cdspell
shopt -s extglob

set -o notify # about terminated jobs

# Programmable completion ~\~1
complete -A alias          a alias alais unalias
complete -A binding        b bind bnid
complete -A command        ? which wihch type tpye
complete -A disabled       en enable
complete -A enabled        di builtin
complete -A export         printenv
complete -A function       function
complete -A hostname       d dig n nslookup snlookup p ping pnig ssh
complete -A user           chage chfn finger groups mail passwd slay su userdel usermod w write
complete -A variable       export local readonly unset

complete -A helptopic      h help # Currently, same as builtin
complete -A signal         k kill klil
complete -A job     -P '%' j z fg jobs disown
complete -A stopped -P '%' bg
complete -A setopt         set o se-o set-o no se+o set+o
complete -A shopt          shopt opt

#complete -o nospace -F _cd cd
complete -A directory -u   cd
complete -A directory      md mkdir rd rmdir # cd

# eXclude what is not(!) matched by the pattern
complete -f -o default -X '!*.@(zip|ZIP|z|Z|gz|GZ|bz2|BZ2)' extract t tar

complete -f -o default -X '!*.php' php    pph
complete -f -o default -X '!*.pl'  perl   prel   pl
complete -f -o default -X '!*.py'  python pyhton py
complete -f -o default -X '!*.rb'  ruby   rbuy   rb

# # Completion of directories or user names (will fail if a directory contains )
# _cd() {
#
#     local cur="${COMP_WORDS[COMP_CWORD]}"
#     local dirlist
#     local userlist
#     local res
#
#     # ex: ~user, not ~/dev
#     if [[ $2 == ~[!/]* ]]; then
#
#         # the default delimiter is \n, IFS '' - read reads several lines
#         # [dir1 \n dir2 \n ... dirn \0 ]      - read reads one line
#         IFS=$'\n' read -r -d $'\0' -a userlist < <(compgen -A user -- "$cur")
#
#         if [[ $userlist ]]; then
#
#             IFS=$'\n' read -r -d $'\0' -a COMPREPLY < <(printf "%q\n" "${userlist[@]}")
#         fi
#     else
#         IFS=$'\n' read -r -d $'\0' -a dirlist < <(compgen -A directory -- "$cur")
#
#         if [[ $dirlist ]]; then
#
#             IFS=$'\n' read -r -d $'\0' -a res < <(printf "%q\n" "${dirlist[@]}")
#
#             for item in "${res[@]}"; do
#
#                 # after removing the first /, there are still /s
#                 if [[ ${item#/} == */* ]]; then
#
#                     COMPREPLY+=("${item##*/}"/)
#                 else
#                     COMPREPLY+=("$item"/)
#                 fi
#             done
#         fi
#     fi
# }

_longopts() {

    COMP_WORDBREAKS="${COMP_WORDBREAKS/=/}"

    local cur="${COMP_WORDS[COMP_CWORD]}"

    [[ ! $cur || $cur != -* ]] && return

    prog="$1"

    [[ $prog == @(v|vmi|gv|gvi|gvmi) ]] && prog=gvim
    [[ $prog == @(m|man|mna) ]]         && prog=man
    [[ $prog == @(l|ll|ld|lld|l.|ll.|la|lla|lr|llr|lk|llk|lx|llx|lv|lc|llc|lm|llm|lu|llu) ]] && prog=ls

    # [\[=]? instead of (\[|=)? ???
    COMPREPLY=($(\
    \
    "$prog" --help |\
    grep -oe '--[[:alpha:]][[:alpha:]-]+(\[|=){0,2}([[:alpha:]-]|_)+\]?' |\
    grep -e "$cur" |\
    sort -u\
    ))

    for i in "${!COMPREPLY[@]}"; do

        if [[ ${COMPREPLY[i]} != *[* ]]; then

            COMPREPLY[i]="${COMPREPLY[i]%]}"
        fi
    done
}

# bash, ls, vim
complete -o default -F _longopts bash ls l ll ld lld l. ll. la lla lr llr lk\
llk lx llx lv lc llc lm llm lu llu v vi vim vmi gv gvi gvim gvmi

# commands and long options
complete -c -F _longopts m man mna

complete -W 'bold dim rev setab setaf sgr0 smul' tp pt tput

complete -W 'alias arrayvar binding builtin command directory disabled enabled
export file function group helptopic hostname job keyword running service
setopt shopt signal stopped user variable' cl compgen complete

complete -F _longopts -W 'add bisect branch checkout clone commit diff fetch
grep init log merge mv pull push rebase reset rm show status tag' git

# Source business specific...

complete -F _longopts -W 'check-update clean deplist erase grouperase groupinfo
groupinstall grouplist groupremove groupupdate info install list localinstall
localupdate makecache provides remove repolist resolvedep search shell update
upgrade whatprovides' yum
