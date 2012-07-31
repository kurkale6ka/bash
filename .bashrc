# Author: Dimitar Dimitrov: mitkofr@yahoo.fr, kurkale6ka

[[ -t 1 ]] || return

shopt -s cdspell
shopt -s extglob
shopt -s nocaseglob
shopt -s nocasematch

set -o notify # about terminated jobs

if command -v vimx >/dev/null 2>&1; then
   my_gvim=vimx
   my_vim="$my_gvim -v"
elif command -v gvim >/dev/null 2>&1; then
   my_gvim=gvim
   my_vim="$my_gvim -v"
else
   my_gvim=vim
   my_vim="$my_gvim"
fi

# Colors: set[af|ab] (ANSI [fore|back]ground) {{{1

# Black="$(tput setaf 0)"
# BlackBG="$(tput setab 0)"
# DarkGrey="$(tput bold ; tput setaf 0)"
# LightGrey="$(tput setaf 7)"
# LightGreyBG="$(tput setab 7)"
# White="$(tput bold ; tput setaf 7)"
# Red="$(tput setaf 1)"
# RedBG="$(tput setab 1)"
  LightRed="$(tput bold ; tput setaf 1)"
# Green="$(tput setaf 2)"
# GreenBG="$(tput setab 2)"
  LightGreen="$(tput bold ; tput setaf 2)"
# Brown="$(tput setaf 3)"
# BrownBG="$(tput setab 3)"
# Yellow="$(tput bold ; tput setaf 3)"
# Blue="$(tput setaf 4)"
# BlueBG="$(tput setab 4)"
  LightBlue="$(tput bold ; tput setaf 4)"
  Purple="$(tput setaf 5)"
# PurpleBG="$(tput setab 5)"
# Pink="$(tput bold ; tput setaf 5)"
# Cyan="$(tput setaf 6)"
# CyanBG="$(tput setab 6)"
# LightCyan="$(tput bold ; tput setaf 6)"
# Bold="$(tput bold)"
  Underline="$(tput smul)"
  Reset="$(tput sgr0)" # No Color

# PS1 and title (\e]2; ---- \a) {{{1
[[ linux != $TERM ]] && title="\e]2;\H\a"

if [[ $SSH_CLIENT || $SSH2_CLIENT ]]
then info=', remote'
else info=''
fi

if ((0 == EUID)); then
   PS1="$title\n\[$LightRed\]\u \H \[$LightBlue\]\w\[$Reset\] - \A, %\j$info\n# "
   export PATH="$PATH":/sbin:/usr/sbin:/usr/local/sbin:/root/bin
else
   PS1="$title\n\[$LightGreen\]\u \H \[$LightBlue\]\w\[$Reset\] - \A, %\j$info\n\$ "
fi

export PS2='↪ '
export PS3='Choose an entry: '
export PS4='+ '

# Functions {{{1

usersee() {
   if (($#)); then
      local header user
      case "$1" in
         -p)
            header=LOGIN:PASSWORD:UID:GID:GECOS:HOME:SHELL
            sed 's/::/:-:/g' /etc/passwd | sort -k7 -t: | sed "1i$header" |\
            column -ts:;;
         -g)
            header=GROUP:PASSWORD:GID:USERS
            sort -k4 -t: /etc/group | sed "1i$header" | column -ts:;;
         -s)
            header=LOGIN:PASSWORD:LAST:MIN:MAX:WARN:INACTIVITY:EXPIRATION:RESERVED
            sed 's/::/:-:/g' /etc/shadow | sort -k2 -t: |\
            awk -F: '{print $1":"substr($2,1,3)":"$3":"$4":"$5":"$6":"$7":"$8":"$9}' |\
            sed "1i$header" | column -ts:;;
          *)
            for user in "$@"; do
               sudo grep -iE --color "$user" /etc/{passwd,shadow}
               sort -k4 -t: /etc/group | column -ts: | grep -iE --color "$user"
            done
      esac
   else
      sudo grep -iE --color "$USER" /etc/{passwd,shadow}
      sort -k4 -t: /etc/group | column -ts: | grep -iE --color "$USER"
   fi
}

hd() {
   if ((1 == $#))
   then hdparm -I "$1"
   else hdparm "$@"
   fi
}

f() {
   if ((1 == $#))
   then find . -iname "$1"
   else find "$@"
   fi
}

n() { sed -n "$1"p "$2"; }

if ! command -v service >/dev/null 2>&1; then
   service() { /etc/init.d/"$1" "${2:-start}"; }
fi

# unzip or uname
u() {
   if (($#)); then
      local arg
      for arg in "$@"; do
         if [[ -f $arg ]]; then
            case "$arg" in
               *.tar.gz  | *.tgz          ) tar zxvf   "$arg";;
               *.tar.bz2 | *.tbz2 | *.tbz ) tar jxvf   "$arg";;
                                    *.tar ) tar xvf    "$arg";;
                                    *.bz2 ) bunzip2    "$arg";;
                                    *.gz  ) gunzip     "$arg";;
                                    *.zip ) unzip      "$arg";;
                                    *.rar ) unrar x    "$arg";;
                                    *.Z   ) uncompress "$arg";;
                                    *.7z  ) 7z x       "$arg";;
               *) echo "'$arg' cannot be extracted!" >&2;;
            esac
         else
            echo "'$arg' is not a valid file" >&2
         fi
      done
   else
      local i
      printf '%23s' 'Distribution: '
      for i in /etc/*{-release,_version}; do
         cat "$i" 2>/dev/null; break
      done
      printf '%23s' 'Network node hostname: ' && uname -n
      printf '%23s' 'Machine hardware name: ' && uname -m
      printf '%23s' 'Hardware platform: '     && uname -i
      printf '%23s' 'Processor type: '        && uname -p
      printf '%23s' 'Kernel name: '           && uname -s
      printf '%23s' 'Kernel release: '        && uname -r
      printf '%23s' 'Compiled on: '           && uname -v
      printf '%23s' 'Operating system: '      && uname -o
   fi
}

m() {
   local topic choice
   for topic in "$@"; do
      if [[ $(type -a $topic 2>/dev/null) == *builtin*/* ]]; then
         select choice in builtin command; do
            case "$choice" in
               builtin) help "$topic"; break;;
               command) man "$topic"; break;;
                     *) echo '*** Wrong choice ***' >&2
            esac
         done
      else
         { man "$topic" || help "$topic" || type -a "$topic"; } 2>/dev/null
      fi
   done
}

# Usage: sw my_file.c [my_file.c~] - my_file.c <=> my_file.c~
# the second arg is optional if it is the same arg with a '~' appended to it
sw() {

   [[ ! -e $1 ]]            && echo "file '$1' does not exist" >&2 && return 1
   [[ 2 == $# && ! -e $2 ]] && echo "file '$2' does not exist" >&2 && return 1

   # todo
   local tmpfile=tmp.$$

   if ((2 == $#)); then

      mv -- "$1"       "$tmpfile"
      mv -- "$2"       "$1"
      mv -- "$tmpfile" "$2"
   else
      mv -- "$1"       "$tmpfile"
      mv -- "$1"~      "$1"
      mv -- "$tmpfile" "$1"~
   fi
}

# Usage: x - toggle debugging on/off
x() {
   if [[ $- == *x* ]]; then
      # todo exec 1>/dev/null...
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

      echo "Usage: $FUNCNAME 'pattern' OR $FUNCNAME -b|--backup" >&2

   elif [[ $1 == @(-b|--backup) ]]; then

      find -name \*~ -a ! -name \*.un~ -exec rm {} +

   else
      find . -name "$1" -exec rm {} +
   fi
}

# Usage: bak my_file1.c, my_file2.c => my_file1.c~, my_file2.c~
bak() { local arg; for arg in "$@"; do cp -- "$arg" "$arg"~; done; }

# Usage: cl arg - computes a completion list for arg
cl() { column <(compgen -A "$1"); }

# Aliases {{{1

# Vim {{{2
alias       v="$my_vim"
alias      vi="$my_vim"
alias     vim="$my_vim"
alias    view="$my_vim  -R"
alias      vd="$my_vim  -d"
alias vimdiff="$my_vim  -d"
alias     gvd="$my_gvim -d"
alias      gv="$my_gvim"
alias     gvi="$my_gvim"

vn() {
   local vim_options[0]='vim'
         vim_options[1]='vim no .vimrc'
         vim_options[2]='vim no plugins'
         vim_options[3]='gvim no .gvimrc'
   local vim
   select vim in "${vim_options[@]}"; do
      case "$vim" in
         "${vim_options[0]}") "$my_gvim" -nNX -u NONE;    break;;
         "${vim_options[1]}") "$my_gvim" -nNX -u NORC;    break;;
         "${vim_options[2]}") "$my_gvim" -nNX --noplugin; break;;
         "${vim_options[3]}") "$my_gvim"  -N  -U NONE;    break;;
                           *) printf '\nInvalid choice!\n' >&2
      esac
   done
}

# alias  vn="$my_vim  -N -u NONE -U NONE"
alias gvn="$my_gvim -N -U NONE"

# List directory contents {{{2
sl() {
   printf '%-8s %-17s %-3s %-4s %-4s %-10s %-12s %-s\n'\
          'Inode' 'Permissions' 'ln' 'UID' 'GID' 'Size' 'Time' 'Name'
   local args=()
   if (($#)); then args=("$@"); else args=(*); fi
   stat -c "%8i %A (%4a) %3h %4u %4g %10s (%10Y) %n" "${args[@]}"
}
alias   l='ls -FB --color=auto'
alias  ll='ls -FB --color=auto -hl --time-style="+(%d %b %y - %H:%M)"'
alias  ld='ls -FB --color=auto -d'
alias lld='ls -FB --color=auto -dhl --time-style="+(%d %b %y - %H:%M)"'
alias  la='ls -FB --color=auto -A'
alias lla='ls -FB --color=auto -Ahl --time-style="+(%d %b %y - %H:%M)"'
alias  lr='ls -FB --color=auto -R'
alias llr='ls -FB --color=auto -Rhl --time-style="+(%d %b %y - %H:%M)"'
alias  lk='ls -FB --color=auto -S'
alias llk='ls -FB --color=auto -Shl --time-style="+(%d %b %y - %H:%M)"'
alias  lx='ls -FB --color=auto -X'
alias llx='ls -FB --color=auto -Xhl --time-style="+(%d %b %y - %H:%M)"'
alias  lv="ls -FB --color=auto|$my_vim -"

alias  l.=ldot
alias ll.=lldot

# todo
.() { if (($#)); then source "$@"; else ldot; fi; }

ldot() {
   if (($#)); then
      local i arg

      for arg in "$@"; do

         [[ $# > 1 ]] && printf '%s:\n' "$arg"

         ls -FB --color=auto -d "$arg".[^.]*

         ((i++))
         [[ $# > 1 && $i != $# ]] && echo
      done
   else
      ls -FB --color=auto -d .[^.]*
   fi
}

lldot() {
   if (($#)); then
      local i arg

      for arg in "$@"; do

         [[ $# > 1 ]] && printf '%s:\n' "$arg"

         ls -FB --color=auto -dhl --time-style="+(%d %b %y - %H:%M)" "$arg".[^.]*

         ((i++))
         [[ $# > 1 && $i != $# ]] && echo
      done
   else
      ls -FB --color=auto -dhl --time-style="+(%d %b %y - %H:%M)" .[^.]*
   fi
}

# List all links in a set of directories
lll() {
   local file
   for file in * .*; do
      if [[ -h $file ]]; then
         command\
         ls -FBAhl --color=auto --time-style="+(%d %b %y - %H:%M)" "$file"
      fi
   done
}

# Usage: _l $1: (change|modif|access), $2: options, $@:3: (all other arguments)
_l() {
   printf '%s%sSorted by %s date:%s \n' "$Purple" "$Underline" "$1" "$Reset"

   ((2 == $#)) && ls -FB --color=auto "$2" && return

   local i arg num
   for arg in "${@:3}"; do

      [[ $# > 3 ]] && printf '%s:\n' "$arg"

      ls -FB --color=auto "$2" "$arg"

      ((i++))
      num=$(($# - 2))
      [[ $# > 3 ]] && ((i != num)) && printf '\n'
   done
}

# Usage: _ll $1: (change|access|...), $2$3: options, $@:4: (llc's... arguments)
_ll() {
   printf '%s%sSorted by %s date:%s \n' "$Purple" "$Underline" "$1" "$Reset"

   ((3 == $#)) && ls -FB --color=auto "$2" "$3" && return

   local i arg num
   for arg in "${@:4}"; do

      [[ $# > 4 ]] && printf '%s:\n' "$arg"

      ls -FB --color=auto "$2" "$3" "$arg"

      ((i++))
      num=$(($# - 3))
      [[ $# > 4 ]] && ((i != num)) && printf '\n'
   done
}

lc()  { _l  change       -tc                                      "$@"; }
lm()  { _l  modification -t                                       "$@"; }
lu()  { _l  access       -tu                                      "$@"; }
llc() { _ll change       -tchl --time-style='+(%d %b %Y - %H:%M)' "$@"; }
llm() { _ll modification -thl  --time-style='+(%d %b %Y - %H:%M)' "$@"; }
llu() { _ll access       -tuhl --time-style='+(%d %b %Y - %H:%M)' "$@"; }

# Change directory {{{2
alias  cd-='cd -'
alias -- -='cd -'
alias    1='cd ..'
alias    2='cd ../..'
alias    3='cd ../../..'
alias    4='cd ../../../..'
alias cd..='cd ..'
alias   ..='cd ..'
alias  ...='cd ../..'

# Help {{{2
alias  ?='type -a'
alias mm='man -k'

db() {
   PS3='Choose a database to update: '
   local prgm
   select prgm in locate 'apropos, man -k'; do
      if [[ $prgm == apropos* ]]
      then printf 'makewhatis...\n'; makewhatis & break
      else printf 'updatedb...\n'; updatedb & break
      fi
   done
}

irssi() {
   (cd /var/log/irssi
   "$HOME"/config/help/.irssi/fnotify.bash &
   command irssi
   kill %?fnotify)
}

# Misc {{{2
alias    c='cat -n'
alias    e=echo
alias    t=tail
alias   tf=tailf
alias    z=fg
alias   ex=export
alias   fr=free
alias   lo='locate -i'
alias   pf=printf
alias   pa='(IFS=:; printf "%s\n" $PATH | sort -u)'
alias   pw='pwd -P'
alias   sc=screen
alias   so=source
alias   to=touch
alias  cmd=command
alias  msg=dmesg
alias env-='env -i'

rc() {
   if (($#)); then
      local rcfile="$HOME"/.inputrc
      xclip -f <(echo "cat >> $rcfile <<'EOF'") "$rcfile" <(echo EOF)
   else
      local inputrc="printf '%s\n' "
      inputrc+="'\"\e[A\": history-search-backward' "
      inputrc+="'\"\e[B\": history-search-forward' >> $HOME/.inputrc"
      xclip -f <<< "$inputrc"
   fi
}

rmi() {
   local i=0 file inodes=()
   for file in "$@"; do
      ((++i < $#)) && inodes+=(-inum "$file" -o)
   done
   inodes+=(-inum "$file")
   find . \( "${inodes[@]}" \) -exec rm -i {} +
}

alias ldapsearch='ldapsearch -x -LLL'

ir() { ifdown "$1" && ifup "$1" || echo "Couldn't do it." >&2; }
alias ipconfig=ifconfig

alias dump='dump -u'
alias bc='bc -l'
alias vish='sudo vipw -s'

if ! [[ $(sudo -V) == *1.6* ]]; then
   alias sudo="sudo -p 'Password for %p: '"
else
   alias sudo="sudo -p 'Password for %u: '"
fi
alias sd=sudo
alias sde=sudoedit

s() {
   if (($# == 2)); then
      # s///, s old new [number|cmd]
      fc -s "$1"="$2" "$3"
   elif (($# == 1)); then
      if [[ $1 == [[:digit:]]* ]]; then
         grep -w -iE --color "$1" /etc/services
      else
         grep    -iE --color "$1" /etc/services
      fi
   else
      # root bash
      if ! [[ $(\sudo -V) == *1.6* ]]; then
         sudo -E /bin/bash
      else
         sudo    /bin/bash
      fi
   fi
}

alias en=enable
alias di='enable -n'

alias     j='jobs -l'
alias -- --='fg %-'

alias pl=perl
alias py='python -i -c "from math import *"'
alias rb=irb

alias  sed='sed -r'
alias seds="echo sed \"'s/old/new/'\" file"
awks() { printf 'awk -F: \047/pattern/ {print $1" "$2}\047 file\n'; }

alias  a=alias
alias ua=unalias

alias se=set
alias use=unset

alias mn='mount | cut -d" " -f1,3,5,6 | column -t'
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

alias pgrep='pgrep -l'
alias pg='ps j --headers | head -1 && ps fajxww | grep -v grep | grep'

alias  k=kill
alias kl='kill -l'
alias ka=killall
alias pk=pkill

if command -v ncal >/dev/null 2>&1; then
   alias cal='env LC_TIME=bg_BG.utf8 ncal -3 -M -C'
   alias call='env LC_TIME=bg_BG.utf8 ncal -y -M -C'
else
   alias cal='env LC_TIME=bg_BG.utf8 cal -m3'
   alias call='env LC_TIME=bg_BG.utf8 cal -my'
fi

alias date="date '+%d %B [%-m] %Y, %H:%M %Z (%A)'"

alias    g='grep -iE --color'

alias   mo="$my_vim -"

h() { if (($#)); then head "$@"; else history; fi; }
b() {
   if (($# == 1)); then
      figlet -f smslant "$1"
   elif (($# == 2)); then
      figlet -f "$1" "${@:2}"
   else
      figlist
   fi
}

alias hg='history | grep -iE --color'
alias r='netstat -rn'
alias i='hostname -i'
alias ii='/sbin/ifconfig'
alias ia='/sbin/ifconfig -a'

alias   o='set -o'
alias  oo=shopt

p() { if (($#)); then ping -c3 "$@"; else ps fjww --headers; fi; }

df() {
   if (($#))
   then command df "$@" | sort -k5r
   else command df -h | sort -k5r
   fi
}

# Fails with \n in filenames!? Try this instead:
# for file in *; do read size _ < <(du -sk "$file");...
d() {
   local args
   if (($#)); then args=("$@"); else args=(*); fi
   if sort -h /dev/null 2>/dev/null
   then
      du -sh "${args[@]}" | sort -hr
   else
      local unit size file
      du -sk "${args[@]}" | sort -nr | while read -r size file
      do
         for unit in K M G T P E Z Y
         do
            if ((size < 1024))
            then
               printf '%3d%s\t%s\n' "$size" "$unit" "$file"
               break
            fi
            size=$((size / 1024))
         done
      done
   fi
}

alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i --preserve-root'

alias md='mkdir -p'

rd() {
   local arg answer
   for arg in "$@"; do
      if [[ -d $arg ]]; then
         if read -r -p "rd: remove directory '$arg'? " answer; then
            [[ $answer == @(y|yes) ]] && rm -rf "$arg"
         fi
      else
         echo "$arg is not a directory" >&2
      fi
   done
}

# Spelling typos {{{2
alias      akw=awk
alias     akws=awks
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
alias      otp=opt
alias      pdw=pwd
alias     pnig=ping
alias      pph=php
alias     prel=perl
alias       pt=tput
alias   pyhton=python
alias     rbuy=ruby
alias      rmm=rrm
alias      rmp=rpm
alias    shotp=shopt
alias snlookup=nslookup
alias     tpye=type
alias     veiw=view
alias      vmi=vim
alias      shh=ssh
# }}}2

# Programmable completion {{{1
complete -A alias          a alias unalias
complete -A binding        bind bnid
complete -A command        ? which wihch type tpye sudo
complete -A disabled       en enable
complete -A enabled        di builtin
complete -A export         printenv
complete -A function       function
complete -A hostname       dig n nslookup snlookup host p ping pnig ssh
complete -A user           chage chfn finger groups mail passwd slay su userdel usermod w write
complete -A variable       export local readonly unset

complete -A helptopic      help hlep m # Currently, same as builtin
complete -A signal         k kill klil
complete -A job     -P '%' j z fg jobs disown
complete -A stopped -P '%' bg
complete -A setopt         set o
complete -A shopt          shopt oo

complete -A directory -F _cd cd
complete -A directory        md mkdir rd rmdir

complete -A file n

# eXclude what is not(!) matched by the pattern
complete -f -o default -X '!*.@(tar.gz|tgz|tar.bz2|tbz2|tbz|tar|bz2|gz|zip|rar|Z|7z)' u
complete -f -o default -X '!*.@(tar.gz|tgz|tar.bz2|tbz2|tbz|tar)' tar

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

         IFS=$'\n' read -r -d $'\0' -a COMPREPLY < <(printf '%q\n' "${userlist[@]}")
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
complete -W 'eth0 eth1 lo' ir
complete -W 'if=/dev/zero' dd

complete -W 'alias arrayvar binding builtin command directory disabled enabled
export file function group helptopic hostname job keyword running service
setopt shopt signal stopped user variable' cl compgen complete

# Business specific or system dependant stuff
[[ -r ~/.bashrc_after ]] && source ~/.bashrc_after

# enable bash completion in interactive shells
if [[ -f /etc/profile.d/bash-completion.sh ]] && ! shopt -oq posix; then
   . /etc/profile.d/bash-completion.sh >/dev/null 2>&1
elif [[ -f /etc/bash_completion ]] && ! shopt -oq posix; then
   . /etc/bash_completion >/dev/null 2>&1
fi
