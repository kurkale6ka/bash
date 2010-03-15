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

title="\e]2;\D{%e %B %Y}, bash $BASH_VERSION on $TERM, [\u@\H]\a" # \e]2; TITLE \a

if (( 0 == UID )); then

    echo 'Hi root'
    PS1="$title\n\[$txt_red\]\D{%a} \A \w [!\! - %\j]\n# \[$txt_rst\]"
else
    echo 'Hi kurkale6ka'
    PS1="$title\n\[$txt_ylw\]\D{%a} \A \[$txt_pur\]\w \[$txt_red\][!\! - %\j]\[$txt_rst\]\n\$ "
fi

# Functions ~\~1
_exit() {

    clear
    echo -e "${txt_red}Hasta la vista, baby${txt_rst}"
}
trap _exit EXIT

# Usage: t my_archive.tar.gz => my_archive/
extract() {

    if [[ -f $1 ]]; then

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
            *)                warn "'$1' cannot be extracted via extract" ;;
        esac
    else
        warn "'$1' is not a valid file"
    fi
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
wc()
{
    counts=($(command wc -lwm "$1"))
    echo "${counts[0]} lines, ${counts[1]} words and ${counts[2]} characters"
}

# Usage: ? arg - show how arg would be interpreted
which() {

    type -a "$1"

    if [[ $(whereis "$1") != *: ]]; then

        whereis "$1"
    fi
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

# Usage: bak my_file.c => my_file.c~
bak() { cp -- "$1" "$1"~; }

# Usage: cl arg - computes a completion list for arg (pb with cl job!)
cl () { compgen -A "$1" | column; }

# Usage: fr '*~' - remove all those files
fr() { find . -name "$1" -exec rm -i {} +; }

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
alias  lk='ls -Sr'
alias llk='ls -Srhl --time-style="+(%d/%m/%Y - %H:%M)"'
alias  lx='ls -X'
alias llx='ls -Xhl --time-style="+(%d/%m/%Y - %H:%M)"'
alias  lv="ls|$MY_VIM -"

lc() { echo -n 'Sorted by change date: '; ls -tc; }

llc() {

    echo -n 'Sorted by change date: '
    ls -tchl --time-style='+(%d/%m/%Y - %H:%M)'
}

lu() { echo -n 'Sorted by access date: '; ls -tu; }

llu() {

    echo -n 'Sorted by access date: '
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
alias  ?=which
alias  i=info
alias  m=man
alias ap=apropos
alias mw=makewhatis

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
alias    wihch=which
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

complete -W 'alias arrayvar binding builtin command directory disabled enabled
export file function group helptopic hostname job keyword running service
setopt shopt signal stopped user variable' cl compgen

# Source business specific...

complete -W '--noplugins check-update clean deplist erase grouperase groupinfo
groupinstall grouplist groupremove groupupdate info install list localinstall
localupdate makecache provides remove repolist resolvedep search shell update
upgrade whatprovides' yum
