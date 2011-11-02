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

# Shell options ~\~1
shopt -s cdspell
shopt -s extglob

set -o notify # about terminated jobs

# PS1 and title ~\~1
if [[ linux != $TERM ]]; then

   title="\e]2;\D{%e %B %Y (%A)}, bash $BASH_VERSION on $TERM\a" # \e]2; TITLE \a
fi

if (( 0 == UID )); then

   PS1="$title\n\[$red\][\u@\H] \w (!\! - %\j, \A)\n# \[$reset\]"
else
   PS1="$title\n\[$yellow\][\u@\H] \[$magenta\]\w \[$red\](!\! - %\j, \A)\[$reset\]\n\$ "
fi

export PS2='↪ '
export PS3='Choose an entry: '
export PS4='+ '

# Checks that vimx is installed
if command -v vimx >/dev/null 2>&1; then

   my_gvim=vimx
else
   my_gvim=gvim
fi
my_vim="$my_gvim -v"

# Functions ~\~1
_exit() {

   echo -e "${red}Hasta la vista, baby$reset"
}
trap _exit EXIT

# Usage: warn 'message' - print a message to stderr
warn() { printf '%s\n' "$@" >&2; }

usersee() {

   for user in "$@"; do

      sudo grep -iE --color "$user" /etc/{passwd,shadow,group}
   done
}

hd() {

   if [[ 1 == $# ]]; then

      hdparm -I "$1"
   else
      hdparm "$@"
   fi
}

f() {

   if [[ 1 == $# ]]; then

      find . -iname "$1"
   else
      find "$@"
   fi
}

n() { sed -n "$1"p "$2"; }

if ! command -v service >/dev/null 2>&1; then
   service() { /etc/init.d/"$1" "$2"; }
fi

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
m() {

   local t="$(type -at "$@")"

   if [[ $t == @(*builtin*|*keyword*) ]]; then

      if [[ $* == *[* && $* != *[[* || $* == *test* ]]; then

         # If I ask for [ or test, I want them both
         help [ test | $my_vim -
      else
         help "$@"
      fi
   else
      man "$@" || info "$@"
   fi
}

# Usage: sw my_file.c [my_file.c~] - my_file.c <=> my_file.c~
# the second arg is optional if it is the same arg with a '~' appended to it
sw() {

   [[ ! -e $1 ]]            && warn "file '$1' does not exist" && return 1
   [[ 2 == $# && ! -e $2 ]] && warn "file '$2' does not exist" && return 1

   local tmpfile=tmp.$$

   if (( 2 == $# )); then

      mv -- "$1"       "$tmpfile"
      mv -- "$2"       "$1"
      mv -- "$tmpfile" "$2"
   else
      mv -- "$1"       "$tmpfile"
      mv -- "$1"~      "$1"
      mv -- "$tmpfile" "$1"~
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

# Usage: rrm/rmm 'pattern' - remove all those files
rrm() {

   if [[ 0 == $# || 1 < $# ]]; then

      warn "Usage: $FUNCNAME 'pattern' OR $FUNCNAME -b|--backup"

   elif [[ $1 == @(-b|--backup) ]]; then

      find -name \*~ -a ! -name \*.un~ -exec rm {} +

   else
      find . -name "$1" -exec rm {} +
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

# Aliases ~\~1

# Vim ~\~2
alias       v="$my_vim"
alias      vi="$my_vim"
alias     vim="$my_vim"
alias    view="$my_vim  -R"
alias      vd="$my_vim  -d"
alias vimdiff="$my_vim  -d"
alias     gvd="$my_gvim -d"
alias      gv="$my_gvim"
alias     gvi="$my_gvim"

vim_options[0]='vim'
vim_options[1]='vim no .vimrc'
vim_options[2]='vim no plugins'
vim_options[3]='gvim no .gvimrc'

vn() {

   select vim in "${vim_options[@]}"; do

   case "$vim" in

      "${vim_options[0]}") "$my_gvim" -v -N -u NONE;;
      "${vim_options[1]}") "$my_gvim" -v -N -u NORC;;
      "${vim_options[2]}") "$my_gvim" -v -N --noplugin;;
      "${vim_options[3]}") "$my_gvim"    -N -U NONE;;
   esac
   break
   done
}

# alias  vn="$my_vim  -N -u NONE -U NONE"
alias gvn="$my_gvim -N -U NONE"

# List directory contents ~\~2
alias   l=ls
alias  ls='ls -FB --color=auto'
alias  ll='ls -hl --time-style="+(%d/%m/%Y - %H:%M)"'
alias  ld='ls -d'
alias lld='ls -dhl --time-style="+(%d/%m/%Y - %H:%M)"'
alias  la='ls -A'
alias lla='ls -Ahl --time-style="+(%d/%m/%Y - %H:%M)"'
alias  lr='ls -R'
alias llr='ls -Rhl --time-style="+(%d/%m/%Y - %H:%M)"'
alias  lk='ls -S'
alias llk='ls -Shl --time-style="+(%d/%m/%Y - %H:%M)"'
alias  lx='ls -X'
alias llx='ls -Xhl --time-style="+(%d/%m/%Y - %H:%M)"'
alias  lv="ls|$my_vim -"

alias pc=lspci

alias  l.=ldot
alias ll.=lldot

ldot() {

   local i

   if [[ $# > 0 ]]; then

      for arg in "$@"; do

         [[ $# > 1 ]] && printf "$arg:\n"

         ls -d "$arg".[^.]*

         (( i++ ))
         [[ $# > 1 && $i != $# ]] && echo
      done
   else
      ls -d .[^.]*
   fi
}

lldot() {

   local i

   if [[ $# > 0 ]]; then

      for arg in "$@"; do

         [[ $# > 1 ]] && printf "$arg:\n"

         ls -dhl --time-style="+(%d/%m/%Y - %H:%M)" "$arg".[^.]*

         (( i++ ))
         [[ $# > 1 && $i != $# ]] && echo
      done
   else
      ls -dhl --time-style="+(%d/%m/%Y - %H:%M)" .[^.]*
   fi
}

# List all links in a set of directories
lll() {

   for file in * .*; do

      if [[ -h $file ]]; then

         command\
         ls -FBAhl --color=auto --time-style="+(%d/%m/%Y - %H:%M)" "$file"
      fi
   done
}

# Usage: _l $1: (change|modif|access), $2: options, $@:3: (all other arguments)
_l() {

   local i

   printf "$magenta${underline}Sorted by $1 date:$reset \n"

   (( 2 == $# )) && ls "$2" && return

   for arg in "${@:3}"; do

      [[ $# > 3 ]] && printf "$arg:\n"

      ls "$2" "$arg"

      (( i++ ))
      local num=$(( $# - 2 ))
      [[ $# > 3 ]] && (( i != num )) && printf "\n"
   done
}

# Usage: _ll $1: (change|access|...), $2$3: options, $@:4: (llc's... arguments)
_ll() {

   local i

   printf "$magenta${underline}Sorted by $1 date:$reset \n"

   (( 3 == $# )) && ls "$2" "$3" && return

   for arg in "${@:4}"; do

      [[ $# > 4 ]] && printf "$arg:\n"

      ls "$2" "$3" "$arg"

      (( i++ ))
      local num=$(( $# - 3 ))
      [[ $# > 4 ]] && (( i != num )) && printf "\n"
   done
}

lc()  { _l  change       -tc                                      "$@"; }
lm()  { _l  modification -t                                       "$@"; }
lu()  { _l  access       -tu                                      "$@"; }
llc() { _ll change       -tchl --time-style='+(%d/%m/%Y - %H:%M)' "$@"; }
llm() { _ll modification -tchl --time-style='+(%d/%m/%Y - %H:%M)' "$@"; }
llu() { _ll access       -tuhl --time-style='+(%d/%m/%Y - %H:%M)' "$@"; }

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
alias    mm='man -k'
alias    mp=manpath

db() {

   select prgm in apropos locate; do

      if [[ apropos == $prgm ]]; then

         makewhatis
         break
      else
         updatedb
      fi
   done
}

alias   lo=locate

# Misc ~\~2
alias     e=echo
alias     t=extract
alias     z=fg
alias    ej=eject
alias    ex=export
alias    fr=free
alias    pf=printf
alias    pp='printf "%s\n"'
alias    pa='(IFS=:; printf "%s\n" $PATH)'
alias    pw=pwd
alias    sc=screen
alias    so=source
alias    to=touch
alias    tp=tput
alias   cmd=command
alias   msg=dmesg
alias   rmm=rrm
alias  env-='env -i'
alias  whoi=whoami
alias uname='uname -a' # function? os() - print all sys info...

ir() { ifdown "$1" && ifup "$1" || echo "Couldn't do it."; }
alias ipconfig=ifconfig
alias dump='dump -u'
alias bc='bc -l'
alias vish='sudo vipw -s'

alias su='sudo su'
alias sd=sudo

alias en=enable
alias di='enable -n'

alias     j='jobs -l'
alias -- --='fg %-'

alias pl=perl
alias py='python -i -c "from math import *"'
alias rb=irb

awk_snip_a='echo awk -F: "'
awk_snip_b="'/pattern/ "
awk_snip_c='{print \$1 \"\\t\" \$2}'
awk_snip_d="'"
awk_snip_e='" file'
alias awks="$awk_snip_a$awk_snip_b$awk_snip_c$awk_snip_d$awk_snip_e"

alias  sed='sed -r' # ERE (Extended regex)
alias seds="echo sed \"'s/old/new/'\" file"

alias am="alias|$my_vim -"
alias  a=alias
alias ua=unalias

alias se=set
alias  u=unset

alias  mn=mount
alias umn=umount

alias cg=chgrp
alias co=chown
alias cm=chmod
alias cr='chmod u+r'
alias cw='chmod u+w'
alias cx='chmod u+x'
alias setuid='chmod u+s'
alias setgid='chmod g+s'
alias setsticky='chmod +t'

alias shutdown='shutdown -h now'

alias ps='ps -ef'
alias pg=pgrep

alias  k=kill
alias kl='kill -l'
alias ka=killall
alias pk=pkill

alias  cal='cal -3 -m'
alias call='cal -y -m'
alias date="date '+%d %B [%-m] %Y, %H:%M %Z (%A)'"

alias    g=grep
alias grep='grep -iE --color' # ERE (Extended regex)

alias less="$my_vim -"
alias more="$my_vim -"
alias   mo=more

alias   b='bind -p'
alias bgg='bind -p|grep'
alias  bm="bind -p|$my_vim -"

alias hi=history
alias hv="history|$my_vim -"
alias  h='history|grep'

alias r='netstat -rn'
alias i='/sbin/ifconfig'
alias ia='/sbin/ifconfig -a'
alias p='ping -c3'

port() { grep -iE --color "$1" /etc/services; }

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
alias rm='rm -i --preserve-root'

# -p lets you create a path structure, ex: mkdir -p /a/b/c
alias mf=mkfifo
alias md='mkdir -p'

rd() {

   for arg in "$@"; do

      if [[ -d $arg ]]; then

         if read -p "rd: remove directory '$arg'? " answer; then

            [[ $answer == @(y|yes) ]] && rm -rf "$arg"
         fi
      else
         warn "$arg is not a directory"
      fi
   done
}

# Spelling typos ~\~2
alias      akw=awk
alias     akws=awks
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

# Programmable completion ~\~1
complete -A alias          a alias alais unalias
complete -A binding        b bind bnid
complete -A command        ? which wihch type tpye sudo
complete -A disabled       en enable
complete -A enabled        di builtin
complete -A export         printenv
complete -A function       function
complete -A hostname       dig n nslookup snlookup host p ping pnig ssh
complete -A user           chage chfn finger groups mail passwd slay su userdel usermod w write
complete -A variable       export local readonly unset

complete -A helptopic      h help hlep m # Currently, same as builtin
complete -A signal         k kill klil
complete -A job     -P '%' j z fg jobs disown
complete -A stopped -P '%' bg
complete -A setopt         set o se-o set-o no se+o set+o
complete -A shopt          shopt opt

complete -A directory -F _cd cd
complete -A directory        md mkdir rd rmdir

complete -A file n

# eXclude what is not(!) matched by the pattern
complete -f -o default -X '!*.@(zip|ZIP|z|Z|gz|GZ|bz2|BZ2)' extract t tar

complete -f -o default -X '!*.php' php    pph
complete -f -o default -X '!*.pl'  perl   prel   pl
complete -f -o default -X '!*.py'  python pyhton py
complete -f -o default -X '!*.rb'  ruby   rbuy   rb

# Completion of user names
_cd() {

   local cur="${COMP_WORDS[COMP_CWORD]}"
   local userlist

   # ex: ~user, not ~/dev
   if [[ $2 == ~[!/]* || $2 == '~' ]]; then

      # the default delimiter is \n, IFS '' - read reads several lines
      # [dir1 \n dir2 \n ... dirn \0 ]      - read reads one line
      IFS=$'\n' read -r -d $'\0' -a userlist < <(compgen -A user -- "$cur")

      if [[ $userlist ]]; then

         IFS=$'\n' read -r -d $'\0' -a COMPREPLY < <(printf "%q\n" "${userlist[@]}")
      fi
   fi
}

# --option
_longopts() {

   COMP_WORDBREAKS="${COMP_WORDBREAKS/=/}"

   local cur="${COMP_WORDS[COMP_CWORD]}"

   # Do not complete if 'cur' doesn't begin with a '-'
   [[ ! $cur || $cur != -* ]] && return

   prog="$1"

   [[ $prog == @(v|vi|vim|vmi|vimx|gv|gvi|gvmi) ]] && prog=gvim
   [[ $prog == @(m|man|mna) ]]                     && prog=man
   [[ $prog == @(l|ll|ld|lld|l.|ll.|la|lla|lr|llr|lk|llk|lx|llx|lv|lc|llc|lm|llm|lu|llu) ]] && prog=ls

   COMPREPLY=($(\
   \
   "$prog" --help |\
   grep -oe '--[[:alpha:]][[:alpha:]-]+[=[]{0,2}[[:alpha:]_-]+]?' |\
   grep -e "$cur" |\
   sort -u\
   ))

   for i in "${!COMPREPLY[@]}"; do

      if [[ ${COMPREPLY[i]} != *[* ]]; then

         COMPREPLY[i]="${COMPREPLY[i]%]}"
      fi
   done
}

# Complete long options for: bash, ls, vim
complete -o default -F _longopts bash ls l ll ld lld l. ll. la lla lr llr lk\
llk lx llx lv lc llc lm llm lu llu v vi vim vmi vimx gv gvi gvim gvmi rpm

# Complete commands and long options for: man
complete -A command -F _longopts m man mna

complete -W 'bold dim rev setab setaf sgr0 smul' tp pt tput

complete -W 'alias arrayvar binding builtin command directory disabled enabled
export file function group helptopic hostname job keyword running service
setopt shopt signal stopped user variable' cl compgen complete

complete -W 'eth0 eth1 lo' ir

# Business specific or system dependant stuff
[[ -r ~/.bashrc_after ]] && source ~/.bashrc_after

# enable bash completion in interactive shells
if [[ -f /etc/bash_completion ]] && ! shopt -oq posix; then
   . /etc/bash_completion >/dev/null 2>&1
fi
