#! /usr/bin/env bash
# Author: Dimitar Dimitrov, kurkale6ka

[[ -t 1 ]] || return

set -o notify
shopt -s cdspell extglob nocaseglob nocasematch histappend

HISTFILESIZE=3000
HISTSIZE=3000 # size allowed in memory
HISTCONTROL=ignorespace:ignoredups:erasedups
HISTIGNORE="@(?|??|???)*( |$'\t'):*( |$'\t')"
# HISTIGNORE='@(?|??|???)*([[:space:]]):*([[:space:]])'
HISTTIMEFORMAT='<%d %b %H:%M>  '

# <tab> completion.
#  ls: ls -B to ignore backup files (~) in listings
# Vim: set wildignore+=*~,*.swp
FIGNORE='~:.swp:.o'
HOSTFILE="$HOME"/.hosts # hostnames completion (same format as /etc/hosts)

# Colors {{{1
# These can't reside in .profile since there is no terminal for tput
     Bold="$(tput bold)"
Underline="$(tput smul)"
   Purple="$(tput setaf 5)"
   LGreen="$(printf %s "$Bold"; tput setaf 2)"
    LBlue="$(printf %s "$Bold"; tput setaf 4)"
     LRed="$(printf %s "$Bold"; tput setaf 1)"
    Reset="$(tput sgr0)"

# Colored man pages
export LESS_TERMCAP_mb="$LGreen" # begin blinking
export LESS_TERMCAP_md="$LBlue"  # begin bold
export LESS_TERMCAP_me="$Reset"  # end mode

# so -> stand out - info box
export LESS_TERMCAP_so="$(printf %s "$Bold"; tput setaf 3; tput setab 4)"
# se -> stand out end
export LESS_TERMCAP_se="$(tput rmso; printf %s "$Reset")"

# us -> underline start
export LESS_TERMCAP_us="$(printf %s%s "$Bold$Underline"; tput setaf 5)"
# ue -> underline end
export LESS_TERMCAP_ue="$(tput rmul; printf %s "$Reset")"

[[ -r $HOME/.dir_colors ]] && eval "$(dircolors "$HOME"/.dir_colors)"

# Vim, sudoedit, sed {{{1
alias       v="command vim -u $HOME/.vimrc"
alias      vi="command vim -u $HOME/.vimrc"
alias     vim="command vim -u $HOME/.vimrc"
alias    view="command vim -u $HOME/.vimrc -R"
alias      vd="command vim -u $HOME/.vimrc -d"
alias vimdiff="command vim -u $HOME/.vimrc -d"
alias    vish='sudo vipw -s'
alias      lv="command ls -B | vim -u $HOME/.vimrc -"
alias      mo="command vim -u $HOME/.vimrc -"

rvd() {
   if (($# < 2)); then
      printf '%s\n' '  Usage: rvd {host} {file1} [file2]' \
                    "example: rvd qa1 ~/.bashrc '~/.bashrc'" >&2
      return 1
   fi
   command vim -u "$HOME"/.vimrc -d "$2" <(ssh "$1" cat "${3:-$2}")
}

if   command -v vimx; then
   my_gvim=vimx
elif command -v gvim; then
   my_gvim=gvim
fi >/dev/null 2>&1

if [[ $my_gvim ]]; then
   alias  gv="command $my_gvim -u $HOME/.vimrc -U $HOME/.gvimrc"
   alias gvi="command $my_gvim -u $HOME/.vimrc -U $HOME/.gvimrc"
   alias gvd="command $my_gvim -u $HOME/.vimrc -U $HOME/.gvimrc -d"
fi

vn() {
   (($#)) && { command vim -NX -u NONE "$@"; return; }
   local opt opts
   local vim="${Bold} vim$Reset"
   local gvi="${Bold}gvim$Reset"
   local  vimrc="${LGreen}.vimrc$Reset"   _vimrc="$HOME"/.vimrc
   local gvimrc="${LGreen}.gvimrc$Reset" _gvimrc="$HOME"/.gvimrc
   local plugin="${LGreen}plugins$Reset"
    opts=("$vim no .vimrc,           , no plugins")
   opts+=(" vim no .vimrc,           ,    $plugin")
   opts+=(" vim    $vimrc,           , no plugins")
   opts+=("$gvi no .vimrc, no .gvimrc, no plugins")
   opts+=("gvim no .vimrc,    $gvimrc,    $plugin")
   opts+=("gvim    $vimrc, no .gvimrc,    $plugin")
   opts+=("gvim no .vimrc, no .gvimrc,    $plugin")
   opts+=("gvim no .vimrc,    $gvimrc, no plugins")
   opts+=("gvim    $vimrc, no .gvimrc, no plugins")
   opts+=("gvim    $vimrc,    $gvimrc, no plugins")
   select opt in "${opts[@]}"; do
      case "$opt" in
         "${opts[0]}") command       vim  -nNX  -u NONE                              ; break;;
         "${opts[1]}") command "$my_gvim" -nNXv -u NORC                              ; break;;
         "${opts[2]}") command       vim  -nNX  -u "$_vimrc"               --noplugin; break;;
         "${opts[3]}") command "$my_gvim" -nN   -u NONE                              ; break;;
         "${opts[4]}") command "$my_gvim" -nN   -u /dev/null -U "$_gvimrc"           ; break;;
         "${opts[5]}") command "$my_gvim" -nN   -u "$_vimrc" -U NONE                 ; break;;
         "${opts[6]}") command "$my_gvim" -nN   -u NORC                              ; break;;
         "${opts[7]}") command "$my_gvim" -nN   -u /dev/null -U "$_gvimrc" --noplugin; break;;
         "${opts[8]}") command "$my_gvim" -nN   -u "$_vimrc" -U NONE       --noplugin; break;;
         "${opts[9]}") command "$my_gvim" -nN   -u "$_vimrc" -U "$_gvimrc" --noplugin; break;;
                    *) printf '\nInvalid choice!\n' >&2
      esac
   done
}

if sudo -V |
   { read -r _ _ ver; ver="${ver%.*}"; ((${ver%.*} > 0 && ${ver#*.} > 6)); }
then alias sudo="sudo -p 'Password for %p: ' ";       sudo_version_ok=1
else alias sudo="sudo -p 'Password for %u: ' "; unset sudo_version_ok
fi
alias  sd=sudo
alias sde=sudoedit

alias sed='sed -r'

# PS1 + title (\e]2; ---- \a) {{{1
PS1() {
   if ((EUID == 0)); then
      [[ $TERM != linux ]] && export PROMPT_COMMAND='printf "\e]2;%s @ %s # %s\a" "$USER" "${HOSTNAME%%.*}" "${PWD/#$HOME/~}"'
      PS1="\n\[$LRed\]\u \[$LBlue\]@ \[$LRed\]\h \[$LBlue\]\w\[$Reset\] \A"'$(((\j>0)) && echo , %\j)'"\n# "
      PATH=$PATH:/sbin:/usr/sbin:/usr/local/sbin:/root/bin:$HOME/bin
   else
      [[ $TERM != linux ]] && export PROMPT_COMMAND='printf "\e]2;%s @ %s $ %s\a" "$USER" "${HOSTNAME%%.*}" "${PWD/#$HOME/~}"'
      PS1="\n\[$LGreen\]\u \[$LBlue\]@ \[$LGreen\]\h \[$LBlue\]\w\[$Reset\] \A"'$(((\j>0)) && echo , %\j)'"\n\\$ "
   fi
}
PS1
PS2='↪ '; export PS3='Choose an entry: '; PS4='+ '

# cd, mkdir | touch, rmdir, pwd {{{1
alias  cd-='c -'
alias -- -='c -'
alias    1='c ..'
alias    2='c ../..'
alias    3='c ../../..'
alias    4='c ../../../..'
alias cd..='c ..'
alias   ..='c ..'
alias   to=touch

[[ -r $HOME/github/bash/scripts/cd/cd.bash ]] && . "$HOME"/github/bash/scripts/cd/cd.bash

pw() {
   if (($#))
   then pws --seconds 25 get "$1"
   else command pwd -P
   fi
}

rd() {
   echo -n 'rd: remove directories '
   local warning
   printf -v warning "'%s', " "$@"
   warning="${warning%??}"; echo -n "$warning? "
   read -r
   [[ $REPLY == @(y|yes) ]] && command rm -rf -- "$@"
}
alias md='command mkdir -p --'
complete -A directory mkdir md rmdir rd

# Completion of user names
_cd() {

   local cur=${COMP_WORDS[COMP_CWORD]}
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
complete -A directory -F _cd cd

# Networking: ip | mac, ping, (ir?). Processes and jobs {{{1
mac() {
   (($#)) && { eix -I "$@"; return 0; }
   local mac_ip_regex='((hw|ll)addr|inet)\s+(addr:)?'
   ifconfig eth0 | command grep -oiE "$mac_ip_regex[^[:space:]]+" |
                   command sed  -r   "s/$mac_ip_regex//i"
}
alias i='curl ifconfig.me/ip'
alias ia='curl ifconfig.me/all 2>/dev/null | column -t'

dig() { command dig +noall +answer "${@#*//}"; }
dg() { dig -x $(dig +noall +answer +short "${@#*//}"); }

# Tunnel host's port to the local port
tunnel() {
   # Help
   if [[ $1 == -@(h|-h)* ]] || (($# == 0))
   then
      local info='Usage: tunnel {host} [{remote port: 80} {local port: 8080}]'
      if (($#))
      then echo "$info"    ; return 0
      else echo "$info" >&2; return 1
      fi
   fi

   if (($# == 1))
   then
      ssh -fNL "${3:-8080}":localhost:"${2:-80}" "$1" &&
      xdg-open http://localhost:"${3:-8080}" 2>/dev/null
   else
      ssh -fNL "${3:-$2}":localhost:"$2" "$1" &&
      xdg-open http://localhost:"${3:-$2}" 2>/dev/null
   fi
}

# Process memory map
pm() {
   for i in "$@"; do
      printf '%s: ' "$i"; pmap -d "$(command pgrep "$i")" | tail -n1
   done | column -t | sort -k4
}

ppfields=pid,ppid,pgid,sid,tname,tpgid,stat,euser,start_time,cmd
pfields=pid,stat,euser,start_time,cmd

p() { if (($#)); then ping -c3 "$@"; else ps fww o "$ppfields" --headers; fi; }

alias pp="ps faxww o $ppfields --headers"
alias pg="ps o $pfields --headers | head -1 && ps faxww o $pfields | command grep -v grep | command grep -iEB1 --color=auto"
alias ppg="ps o $ppfields --headers | head -1 && ps faxww o $ppfields | command grep -v grep | command grep -iEB1 --color=auto"
alias pgrep='pgrep -l'

alias  k=kill
alias kl='kill -l'
alias ka=killall
alias kg='kill -- -'
alias pk=pkill
complete -A signal kill k

alias     j='jobs -l'
alias     z=fg
alias -- --='fg %-'
complete -A job     -P '%' fg z jobs j disown
complete -A stopped -P '%' bg

# todo: keep?
ir() { ifdown "$1" && ifup "$1" || echo "Couldn't do it." >&2; }
complete -W 'eth0 eth1 lo' ir

rs() {
   (($# == 3)) || { echo 'Usage: rs USER SERVER DIR' >&2; return 1; }
   [[ $1 == 'root' ]] && local home='' || local home=home/
   rsync -e "ssh -l $1" -v --recursive --links --stats --progress --exclude-from \
      "$HOME"/config/dotfiles/.rsync_exclude "${3%/}"/ "$2:/$home$1/${3%/}"
}

# Permissions + debug + netstat, w {{{1
r() { if [[ -d $1 || -f $1 ]]; then chmod u+r -- "$@"; else netstat -rn; fi; }
w() { if [[ -d $1 || -f $1 ]]; then chmod u+w -- "$@"; else command w "$@"; fi; }
alias    setuid='chmod u+s'
alias    setgid='chmod g+s'
alias setsticky='chmod  +t'
alias        cg=chgrp
alias        co=chown
alias        cm=chmod

x() {
   (($#)) && { chmod u+x -- "$@"; return; }
   if [[ $- == *x* ]]
   then echo 'debug OFF'; set +o xtrace
   else echo 'debug ON' ; set -o xtrace
   fi
} 2>/dev/null
alias bx='bash -x'

# Info: pa, usersee {{{1
pa() {
   local paths
   IFS=: read -ra paths <<< "$PATH"; printf '%s\n' "${paths[@]}" | awk '!_[$1]++'
}

usersee() {
   if (($#)); then
      local header user
      case "$1" in
         -p)
            header=LOGIN:PASSWORD:UID:GID:GECOS:HOME:SHELL
            sort -k7 -t: /etc/passwd | command sed -e "1i$header" -e 's/::/:-:/g' |\
            column -ts:;;
         -g)
            header=GROUP:PASSWORD:GID:USERS
            sort -k4 -t: /etc/group | command sed "1i$header" | column -ts:;;
         -s)
            header=LOGIN:PASSWORD:LAST:MIN:MAX:WARN:INACTIVITY:EXPIRATION:RESERVED
            sudo sort -k2 -t: /etc/shadow |\
            awk -F: '{print $1":"substr($2,1,3)":"$3":"$4":"$5":"$6":"$7":"$8":"$9}' |\
            command sed -e "1i$header" -e 's/::/:-:/g' | column -ts:;;
          *)
            for user in "$@"; do
               sudo grep -iE --color=auto "$user" /etc/{passwd,shadow}
               sort -k4 -t: /etc/group | column -ts: | command grep -iE --color=auto "$user"
            done
      esac
   else
      sudo grep -iE --color=auto "$USER" /etc/{passwd,shadow}
      sort -k4 -t: /etc/group | column -ts: | command grep -iE --color=auto "$USER"
   fi
}

# ls {{{1
ldot() {
   local ls
   if [[ ${FUNCNAME[1]} == 'l.' ]]
   then ls=(ls -FB   --color=auto)
   else ls=(ls -FBhl --color=auto --time-style='+(%d %b %Y - %H:%M)')
   fi
   (($# == 0)) && {             "${ls[@]}" -d .[^.]* ; return; }
   (($# == 1)) && { (cd "$1" && "${ls[@]}" -d .[^.]*); return; }
   local i arg
   for arg in "$@"; do
      printf '%s:\n' "$arg"
      (cd -- "$arg" && "${ls[@]}" -d .[^.]*)
      (($# != ++i)) && echo
   done
}
.() {
   if (($#))
   then source "$@"
   else command ls -FB --color=auto -d .[^.]*
   fi
}

unalias l. ll. l ld la lr lk lx ll lld lla llr llk llx lm lc lu llm llc llu ln \
   2>/dev/null

 l.() { ldot "$@"; }
ll.() { ldot "$@"; }

alias   l='command ls -FB    --color=auto'
alias  ll='command ls -FBhl  --color=auto --time-style="+(%d %b %Y - %H:%M)"'

alias  la='command ls -FBA   --color=auto'
alias lla='command ls -FBAhl --color=auto --time-style="+(%d %b %Y - %H:%M)"'

alias  ld='command ls -FBd   --color=auto'
alias lld='command ls -FBdhl --color=auto --time-style="+(%d %b %Y - %H:%M)"'

alias  lk='command ls -FBS   --color=auto'
alias llk='command ls -FBShl --color=auto --time-style="+(%d %b %Y - %H:%M)"'

alias  lr="tree -AC -I '*~' --noreport"
alias llr='command ls -FBRhl --color=auto --time-style="+(%d %b %Y - %H:%M)"'

lm() {
   [[ -t 1 ]] && echo "$Purple${Underline}Sorted by modification date:$Reset"
   command ls -FBtr --color=auto "$@"
}
llm() {
   [[ -t 1 ]] && echo "$Purple${Underline}Sorted by modification date:$Reset"
   command ls -FBhltr --color=auto --time-style='+(%d %b %Y - %H:%M)' "$@"
}

_lx() {
   local exes=()
   for x in *; do [[ -x $x ]] && exes+=("$x"); done
   if [[ ${FUNCNAME[1]} == 'lx' ]]; then
      command ls -FB   --color=auto                                    "${exes[@]}"
   else
      command ls -FBhl --color=auto --time-style='+(%d %b %Y - %H:%M)' "${exes[@]}"
   fi
}
 lx() { _lx "$@"; }
llx() { _lx "$@"; }

ln() {
   if (($#)); then
      command ln "$@"
   else
      if (( $(find . -maxdepth 1 -type l -print -quit | wc -l) == 1 )); then
         find . -maxdepth 1 -type l -printf '%P\0' |
         xargs -0 'ls' -FBAhl --color=auto --time-style="+(%d %b %Y - %H:%M)" --
      fi
   fi
}

sl() {
   printf '%-8s %-17s %-3s %-4s %-4s %-10s %-12s %-s\n'\
          'Inode' 'Permissions' 'ln' 'UID' 'GID' 'Size' 'Time' 'Name'
   local args=(); (($#)) && args=("$@") || args=(*)
   stat -c "%8i %A (%4a) %3h %4u %4g %10s (%10Y) %n" -- "${args[@]}"
}

# Help, mv, cp ,rm {{{1
m() {
   local choice
   (($#)) || {
      select choice in help man; do
         case "$choice" in
            help) help help; return;;
             man) man  man ; return;;
               *) echo '*** Wrong choice ***' >&2
         esac
      done
   }
   (($# >= 2)) && [[ -f $1 ]] && { command mv -i -- "$@"; return; }
   local topic arg
   for topic in "$@"; do
      ((arg++))
      [[ $topic == [1-8]* ]] && { man "$topic" -- "${@:$((arg+1))}"; return; }
      if [[ $(type -at -- $topic 2>/dev/null) == builtin*file ]]; then
         select choice in "help $topic" "man $topic"; do
            case "$choice" in
               help*) help -- "$topic"; break;;
                man*) man  -- "$topic"; break;;
                   *) echo '*** Wrong choice ***' >&2
            esac
         done
      else
         { help -- "$topic" || man -- "$topic" || type -a -- "$topic"; } 2>/dev/null
      fi
   done
}
alias mm='man -k'

doc() {
   curl -s https://raw.github.com/kurkale6ka/help/master/"$1".txt
}

complete -A helptopic help m # Currently, same as builtin
complete -A command   man m which whereis type ? tpye sudo

_type() {
   (($#)) || { type -a -- "$FUNCNAME"; return; }

   echo "${Bold}type -a (exe, alias, builtin, func):$Reset"
   type -a -- "$@" 2>/dev/null
   echo

   echo "${Bold}whereis -b (bin):$Reset"
   whereis -b "$@"
   echo

   echo "${Bold}file -L (deref):$Reset"
   local f
   for f in "$@"
   do
      file -L "$(type -P -- "$f")"
   done
}
alias ?=_type

db() {
   local prgm PS3='Choose a database to update: '
   select prgm in locate 'apropos, man -k'; do
      case "$prgm" in
           locate) printf 'updatedb...\n'  ; updatedb   & return;;
         apropos*) printf 'makewhatis...\n'; makewhatis & return;;
                *) echo '*** Wrong choice ***' >&2
      esac
   done
}

alias y='cp -i --'
alias d='rm -i --preserve-root --'

di() {
   local i=0 file inodes=()
   for file in "$@"; do
      ((++i < $#)) && inodes+=(-inum "$file" -o)
   done
   inodes+=(-inum "$file")
   find . \( "${inodes[@]}" \) -exec command rm -i -- {} +
}

mp() { pe-man puppet-"${1:-help}"; }
mpp() { puppet describe "$@" | mo; }
mg() { man git-"${1:-help}"; }

alias rg="cat $HOME/github/help/it/regex.txt"

alias wgetpaste='wgetpaste -s dpaste -n kurkale6ka -Ct'

# Find files, text, differences. 'Cat' files, echo text {{{1
f() { if (($# == 1)); then find . -iname "*$1*"; else find "$@"; fi; }
alias parallel='parallel --no-notice'

alias gr='command grep -nIriE --color=auto --exclude="*~" --exclude tags'
grr() {
   find "${2:-.}" -type f ! -name '*~' ! -name tags -exec grep -nIriE --color=auto "$1" {} +
}
alias          g='command grep -niE --color=auto --exclude="*~" --exclude tags'
alias         lo='command locate -i'
alias ldapsearch='ldapsearch -x -LLL'

diff() {
   if [[ -t 1 ]] && command -v colordiff >/dev/null 2>&1
   then         colordiff "$@"
   else command      diff "$@"
   fi
}
alias _=combine

alias pf=printf
 e() { local status=$?; (($#)) && echo "$@" || echo "$status"; }
cn() { if [[ -t 1 ]]; then command cat -n -- "$@"; else command cat "$@"; fi; }
 n() { command sed -n "$1{p;q}" -- "$2"; }
sq() { command grep -v '^[[:space:]]*#\|^[[:space:]]*$' -- "$@"; }
 h() { if (($#)) || [[ ! -t 0 ]]; then head "$@"; else history; fi; }
alias  t=tail
alias tf=tailf

# Convert to dec, bin, oct, hex + bc {{{1
cv() {
   (($#)) || { echo 'Usage: cv digit ...' >&2; return 1; }
   cvs[0]='Decimal to binary'
   cvs[1]='Decimal to octal'
   cvs[2]='Decimal to hexadecimal'
   cvs[3]='Binary to decimal'
   cvs[4]='Octal to decimal'
   cvs[5]='Hexadecimal to decimal'
   local cv PS3='.? '
   select cv in "${cvs[@]}"; do
      case "$cv" in
         "${cvs[0]}")
            while read -r; do
               printf '%d -> %d\n' "$1" "$REPLY"; shift
            done < <(IFS=';'; command bc -q <<< "obase=2; $*") |\
            command sed '1iDec -> Bin' | column -t
            break;;
         "${cvs[1]}")
            while (($#)); do printf '%d -> %o\n' "$1" "$1"; shift; done |\
            command sed '1iDec -> Oct' | column -t
            break;;
         "${cvs[2]}")
            while (($#)); do printf '%d -> %x\n' "$1" "$1"; shift; done |\
            command sed '1iDec -> Hex' | column -t
            break;;
         "${cvs[3]}")
            while (($#)); do printf '%d -> %d\n' "$1" "$((2#$1))"; shift; done |\
            command sed '1iBin -> Dec' | column -t
            break;;
         "${cvs[4]}")
            while (($#)); do printf '%d -> %d\n' "$1" "$((8#$1))"; shift; done |\
            command sed '1iOct -> Dec' | column -t
            break;;
         "${cvs[5]}")
            while (($#)); do printf '%s -> %d\n' "$1" "$((16#$1))"; shift; done |\
            command sed '1iHex -> Dec' | column -t
            break;;
                   *) printf '\nInvalid choice!\n' >&2
      esac
   done
}
alias bc='bc -ql'

# Date and calendar {{{1
date() {
   if (($#))
   then command date "$@"
   else command date '+%A %d %B %Y, %H:%M %Z (%d/%m/%Y)'
   fi
}
if command -v ncal >/dev/null 2>&1; then
   alias  cal='env LC_TIME=bg_BG.utf8 ncal -3 -M -C'
   alias call='env LC_TIME=bg_BG.utf8 ncal -y -M -C'
else
   alias  cal='env LC_TIME=bg_BG.utf8 cal -m3'
   alias call='env LC_TIME=bg_BG.utf8 cal -my'
fi

# uname {{{1
u() {
   uname -r
   echo "$(uname -mpi) (machine, proc, platform)"
}
alias os='tail -n99 /etc/*{release,version} 2>/dev/null | cat -s'

# Backups {{{1
bak() { local arg; for arg in "$@"; do command cp -i -- "$arg" "$arg".bak; done; }

# Usage: sw file1 [file2]. If file2 is omitted, file1 is swapped with file1.bak
sw() {
   if (($# == 1)); then
      [[ ! -e $1.bak ]] && { echo "file $1.bak does not exist" >&2; return 2; }
      local tmpfile
      tmpfile=$(mktemp tmp.XXXXXXXXXXX) ||
         { echo "Temporary file creation failure" >&2; return 11; }
      command mv -- "$1"       "$tmpfile" &&
              mv -- "$1".bak   "$1"       &&
              mv -- "$tmpfile" "$1".bak
   elif (($# == 2));then
      [[ ! -e $2 ]] && { echo "file $2 does not exist" >&2; return 3; }
      local tmpfile
      tmpfile=$(mktemp tmp.XXXXXXXXXXX) ||
         { echo "Temporary file creation failure" >&2; return 12; }
      command mv -- "$1"       "$tmpfile" &&
              mv -- "$2"       "$1"       &&
              mv -- "$tmpfile" "$2"
   fi
}

# todo: 'rm' not 'rm' -i + cron job ?!
bakrm() { find . -name '*~' -a ! -name '*.un~' -exec command rm -i -- {} +; }

alias dump='dump -u'

# Disk: df, du, hdparm, mount {{{1
df() { command df -hT "$@" | sort -k6r; }

# todo + change name?
# Fails with \n in filenames!? Try this instead:
# for file in *; do read size _ < <(du -sk "$file");...
duu() {
   local args=(); (($#)) && args=("$@") || args=(*)
   if sort -h /dev/null 2>/dev/null
   then
      du -sh -- "${args[@]}" | sort -hr
   else
      local unit size file
      du -sk -- "${args[@]}" | sort -nr | while read -r size file
      do
         for unit in K M G T P E Z Y
         do
            if ((size < 1024))
            then
               printf '%3d%s\t%s\n' "$size" "$unit" "$file"
               break
            fi
            ((size = size / 1024))
         done
      done
   fi
}

hd() { if ((1 == $#)); then hdparm -I -- "$1"; else hdparm "$@"; fi; }

mn() {
   if (($#))
   then command mount "$@"
   else command mount | cut -d" " -f1,3,5,6 | column -t
   fi
}
alias umn=umount
alias  fu='sudo fuser -mv'

# Misc: weechat, .inputrc, s(fc, services, sudo bash), figlet, service + aliases {{{1
alias  a=alias
alias ua=unalias
complete -A alias alias a unalias ua

alias  o='set -o'
alias oo=shopt
complete -A setopt set   o
complete -A  shopt shopt oo

alias       se=set
alias      use=unset
alias      msg=dmesg
alias      cmd=command
alias builtins='enable -a | cut -d" " -f2  | column'
alias open=xdg-open

alias pl=perl
alias rb=irb

complete -f -o default -X '!*.pl' perl   prel pl
complete -f -o default -X '!*.py' python py
complete -f -o default -X '!*.rb' ruby   rb

weechat() {
   flamethrower >/dev/null 2>&1 &
   TERM=xterm-256color weechat-curses
   kill %?flamethrower
}

rc() {
   if (($#)); then
      local rcfile=$HOME/.inputrc
      xclip -f <(echo "command cat >> $rcfile <<'EOF'") "$rcfile" <(echo EOF)
   else
      local inputrc="printf '%s\n' "
      inputrc+="'\"\e[A\": history-search-backward' "
      inputrc+="'\"\e[B\": history-search-forward' >> $HOME/.inputrc"
      xclip -f <<< "$inputrc"
   fi
}

s() {
   if (($# == 2)); then
      # s old new [number|cmd]
      fc -s "$1"="$2" "$3"
   elif (($# == 1)); then
      # s ftp|21
      if [[ $1 == [[:digit:]]* ]]
      then command grep -w -iE --color=auto -- "$1" /etc/services
      else command grep    -iE --color=auto -- "$1" /etc/services
      fi
   else
      history -a
      if [[ $sudo_version_ok ]]
      then sudo -E /bin/bash
      else sudo    /bin/bash
      fi
   fi
}
alias hg='history | command grep -iE --color=auto'

if ! command -v service >/dev/null 2>&1
then service() { /etc/init.d/"$1" "${2:-start}"; }
fi

b() {
   if   (($# == 1)); then figlet -f smslant -- "$1"
   elif (($# == 2)); then figlet -f "$1"    -- "${@:2}"
   else                   figlist | column -c"$COLUMNS"
   fi
}

alias pu=puppet

# Debian
alias ap='sudo aptitude'

complete -W 'update upgrade install remove autoremove purge source build-dep
dist-upgrade dselect-upgrade clean autoclean check' apt-get

complete -W 'add gencaches showpkg showsrc stats dump dumpavail unmet search
show depends rdepends pkgnames dotty xvcg policy' apt-cache

complete -W 'install remove purge hold unhold markauto unmarkauto
forbid-version update safe-upgrade full-upgrade forget-new search show clean
autoclean changelog download reinstall why why-not' ap aptitude

# Git
alias git='LESS="-r -i -M -PM?f%f - :.?L%L lines, :.?ltL\:%lt:.?pB, %pB\% : .?e(Bottom)%t" command git'
gc() {
   if (($#))
   then git commit -v "$@"
   else git commit -va
   fi
}
alias gp='git push origin master'
alias gs='git status'
alias go='git checkout'
alias gm='git checkout master'
alias ga='git add'
alias gb='git branch'
alias gd='git diff'
alias gf='git fetch'

gh() {
   if [[ $1 == -@(h|-h)* ]]
   then
      echo 'Usage: gh [origin|-b|-i|-p|-c]'; return 0
   fi

   local origin
   [[ $1 != -* ]] && origin="${1}"
   local remote=remote."${origin:-origin}".url

   local giturl="$(git config --get "$remote")"
   [[ $giturl ]] || {
      echo "Not a git repository or no $remote set"
      return 1
   }

   local branch
   branch="$(git symbolic-ref HEAD 2>/dev/null)" || branch='(unnamed branch)'
   branch="${branch#refs/heads/}"

   giturl=https://github.com/"${giturl#*:}"

   local path
   case "$1" in
      -b) path=branches;;
      -i) path=issues;;
      -p) path=pulls;;
      -c) path=commits/"$branch";;
       *) path=tree/"$branch";;
   esac
   giturl="${giturl%.git}"/"$path"

   xdg-open "$giturl" 2>/dev/null
}

gsa() (
for repo in bash config help scripts vim; do
   echo "$Bold=== $repo ===$Reset"
   cd "$HOME"/github/"$repo" && git status
   [[ $repo != vim ]] && echo
done
)

complete -W 'HEAD add bisect branch checkout clone commit diff fetch grep init
log merge mv pull push rebase revert reset rm show status tag' git

# Gentoo
alias exi=eix

# Typos {{{1
alias ecex=exec
alias akw=awk
alias rmp=rpm
alias shh=ssh
alias xlcip=xclip

# Programmable completion {{{1
complete -A enabled  builtin
complete -A disabled enable
complete -A export   printenv
complete -A variable export local readonly unset use
complete -A function function
complete -A binding  bind
complete -A user     chage chfn finger groups mail passwd slay su userdel \
                     usermod w write
complete -A hostname dig nslookup snlookup host p ping pnig ssh shh

# Usage: cl arg - computes a completion list for arg
cl() { column <(compgen -A "$1"); }

complete -W 'alias arrayvar binding builtin command directory disabled enabled
export file function group helptopic hostname job keyword running service
setopt shopt signal stopped user variable' cl compgen complete

complete -o default -W 'apply notify resource file package service exec cron
user group' mp mpp pu puppet

# enable bash completion in non posix shells
if ! shopt -oq posix; then
   if [[ -f /etc/profile.d/bash-completion.sh ]]; then
      . /etc/profile.d/bash-completion.sh
   elif [[ -f /etc/bash_completion ]]; then
      . /etc/bash_completion
   fi >/dev/null 2>&1
fi

# Business specific or system dependant stuff {{{1
[[ -r $HOME/.bashrc_after ]] && . "$HOME"/.bashrc_after
