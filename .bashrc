# Author: Dimitar Dimitrov: mitkofr@yahoo.fr, kurkale6ka

[[ -t 1 ]] || return

set -o notify
shopt -s cdspell extglob nocaseglob nocasematch

if command -v vimx >/dev/null 2>&1; then
   my_gvim=vimx
   my_vim="$my_gvim -v"
elif command -v gvim >/dev/null 2>&1; then
   my_gvim=gvim
   my_vim="$my_gvim -v"
else
   my_gvim=vim
   my_vim=$my_gvim
fi

   Purple=$(tput setaf 5)
Underline=$(tput smul)
    Reset=$(tput sgr0)

# PS1 + title (\e]2; ---- \a), PS2, PS3 and PS4 {{{1

PS1() {
   local   LightRed=$(tput bold; tput setaf 1)
   local LightGreen=$(tput bold; tput setaf 2)
   local  LightBlue=$(tput bold; tput setaf 4)

   [[ $TERM != linux ]] && printf "\e]2;$HOSTNAME\a"
   unset PROMPT_COMMAND

   [[ $SSH_CLIENT || $SSH2_CLIENT ]] && info=', remote' || info=''

   if ((EUID == 0)); then
      PS1="\n\[$LightRed\]\u \H \[$LightBlue\]\w\[$Reset\] - \A, %\j$info\n# "
      export PATH=$PATH:/sbin:/usr/sbin:/usr/local/sbin:/root/bin
   else
      PS1="\n\[$LightGreen\]\u \H \[$LightBlue\]\w\[$Reset\] - \A, %\j$info\n\\$ "
   fi
}
PS1

export PS2='↪ '
export PS3='Choose an entry: '
export PS4='+ '

# Aliases {{{1

alias        cg=chgrp
alias        co=chown
alias        cm=chmod
alias        cr='chmod u+r'
alias        cw='chmod u+w'
alias        cx='chmod u+x'
alias    setuid='chmod u+s'
alias    setgid='chmod g+s'
alias setsticky='chmod +t'

alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i --preserve-root'
alias md='command mkdir -p'
alias pw='command pwd -P'
alias lo='command locate -i'
alias to=touch
alias  g='command grep -iE --color'
alias  t=tail
alias tf=tailf
alias  _=combine

alias  cd-='cd -'
alias -- -='cd -'
alias    1='cd ..'
alias    2='cd ../..'
alias    3='cd ../../..'
alias    4='cd ../../../..'
alias cd..='cd ..'
alias   ..='cd ..'

alias       v=$my_vim
alias      vi=$my_vim
alias     vim=$my_vim
alias    view="$my_vim  -R"
alias      vd="$my_vim  -d"
alias vimdiff="$my_vim  -d"
alias     gvd="$my_gvim -d"
alias      gv=$my_gvim
alias     gvi=$my_gvim
alias    vish='sudo vipw -s'
alias      lv="command ls -B | $my_vim -"
alias      mo="$my_vim -"

if sudo -V |
   { read -r _ _ ver; IFS=. read -r maj min _ <<<"$ver"; ((maj > 0 && min > 6)); }
then alias sudo="sudo -p 'Password for %p: '"
else alias sudo="sudo -p 'Password for %u: '"
fi
alias  sd=sudo
alias sde=sudoedit

alias   a=alias
alias  ua=unalias
alias   o='set -o'
alias  oo=shopt
alias  se=set
alias use=unset

alias          ?=_type
alias         mm='man -k'
alias         mn='command mount | cut -d" " -f1,3,5,6 | column -t'
alias        umn=umount
alias         bx='bash -x'
alias   builtins='enable -a | cut -d" " -f2  | column'
alias         pf=printf
alias        cmd=command
alias ldapsearch='ldapsearch -x -LLL'
alias        msg=dmesg
alias        sed='sed -r'
alias       dump='dump -u'
alias         bc='bc -ql'
alias         hg='history | command grep -iE --color'

alias     j='jobs -l'
alias     z=fg
alias -- --='fg %-'
alias     k=kill
alias    kl='kill -l'
alias    ka=killall
alias    pk=pkill
alias pgrep='pgrep -l'
alias    pg='ps j --headers | head -1 && ps fajxww | command grep -v grep |
             command grep -iE --color'

alias        r='netstat -rn'
alias        i='hostname -i'
alias       ii='/sbin/ifconfig'
alias       ia='/sbin/ifconfig -a'
alias ipconfig=ifconfig

if command -v ncal >/dev/null 2>&1; then
   alias  cal='env LC_TIME=bg_BG.utf8 ncal -3 -M -C'
   alias call='env LC_TIME=bg_BG.utf8 ncal -y -M -C'
else
   alias  cal='env LC_TIME=bg_BG.utf8 cal -m3'
   alias call='env LC_TIME=bg_BG.utf8 cal -my'
fi

alias pl=perl
alias py='python -i -c "from math import *"'
alias rb=irb

alias   akw=awk
alias   cta=cat
alias  pnig=ping
alias  prel=perl
alias   rmp=rpm
alias shotp=shopt
alias  tpye=type
alias   vmi=vim
alias   shh=ssh

# ls {{{1

ldot() {
   local ls
   if [[ ${FUNCNAME[1]} == 'l.' ]]; then
      [[ -t 1 ]] && ls=(ls -FB --color=auto) || ls=(ls -FB)
   else
      if [[ -t 1 ]]
      then ls=(ls -FBhl --color=auto --time-style='+(%d %b %y - %H:%M)')
      else ls=(ls -FBhl              --time-style='+(%d %b %y - %H:%M)')
      fi
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
   if (($#)); then
      source "$@"
   else
      if [[ -t 1 ]]
      then command ls -FB --color=auto -d .[^.]*
      else command ls -FB              -d .[^.]*
      fi
   fi
}
 l.() { ldot "$@"; }
ll.() { ldot "$@"; }

l() {
   if [[ -t 1 ]]
   then command ls -FB --color=auto "$@"
   else command ls -FB              "$@"
   fi
}
ld() {
   if [[ -t 1 ]]
   then command ls -FBd --color=auto "$@"
   else command ls -FBd              "$@"
   fi
}
la() {
   if [[ -t 1 ]]
   then command ls -FBA --color=auto "$@"
   else command ls -FBA              "$@"
   fi
}
lr() {
   if [[ -t 1 ]]
   then command ls -FBR --color=auto "$@"
   else command ls -FBR              "$@"
   fi
}
lk() {
   if [[ -t 1 ]]
   then command ls -FBS --color=auto "$@"
   else command ls -FBS              "$@"
   fi
}
lx() {
   if [[ -t 1 ]]
   then command ls -FBX --color=auto "$@"
   else command ls -FBX              "$@"
   fi
}

ll() {
   if [[ -t 1 ]]
   then command ls -FBhl --color=auto --time-style='+(%d %b %y - %H:%M)' "$@"
   else command ls -FBhl              --time-style='+(%d %b %y - %H:%M)' "$@"
   fi
}
lld() {
   if [[ -t 1 ]]
   then command ls -FBdhl --color=auto --time-style='+(%d %b %y - %H:%M)' "$@"
   else command ls -FBdhl              --time-style='+(%d %b %y - %H:%M)' "$@"
   fi
}
lla() {
   if [[ -t 1 ]]
   then command ls -FBAhl --color=auto --time-style='+(%d %b %y - %H:%M)' "$@"
   else command ls -FBAhl              --time-style='+(%d %b %y - %H:%M)' "$@"
   fi
}
llr() {
   if [[ -t 1 ]]
   then command ls -FBRhl --color=auto --time-style='+(%d %b %y - %H:%M)' "$@"
   else command ls -FBRhl              --time-style='+(%d %b %y - %H:%M)' "$@"
   fi
}
llk() {
   if [[ -t 1 ]]
   then command ls -FBShl --color=auto --time-style='+(%d %b %y - %H:%M)' "$@"
   else command ls -FBShl              --time-style='+(%d %b %y - %H:%M)' "$@"
   fi
}
llx() {
   if [[ -t 1 ]]
   then command ls -FBXhl --color=auto --time-style='+(%d %b %y - %H:%M)' "$@"
   else command ls -FBXhl              --time-style='+(%d %b %y - %H:%M)' "$@"
   fi
}

lm() {
   if [[ -t 1 ]]; then
      echo "$Purple${Underline}Sorted by modification date:$Reset"
      command ls -FBt --color=auto "$@"
   else
      command ls -FBt              "$@"
   fi
}
lc() {
   if [[ -t 1 ]]; then
      echo "$Purple${Underline}Sorted by change date:$Reset"
      command ls -FBtc --color=auto "$@"
   else
      command ls -FBtc              "$@"
   fi
}
lu() {
   if [[ -t 1 ]]; then
      echo "$Purple${Underline}Sorted by access date:$Reset"
      command ls -FBtu --color=auto "$@"
   else
      command ls -FBtu              "$@"
   fi
}
llm() {
   if [[ -t 1 ]]; then
      echo "$Purple${Underline}Sorted by modification date:$Reset"
      command ls -FBhlt --color=auto --time-style='+(%d %b %Y - %H:%M)' "$@"
   else
      command ls -FBhlt              --time-style='+(%d %b %Y - %H:%M)' "$@"
   fi
}
llc() {
   if [[ -t 1 ]]; then
      echo "$Purple${Underline}Sorted by change date:$Reset"
      command ls -FBhltc --color=auto --time-style='+(%d %b %Y - %H:%M)' "$@"
   else
      command ls -FBhltc              --time-style='+(%d %b %Y - %H:%M)' "$@"
   fi
}
llu() {
   if [[ -t 1 ]]; then
      echo "$Purple${Underline}Sorted by access date:$Reset"
      command ls -FBhltu --color=auto --time-style='+(%d %b %Y - %H:%M)' "$@"
   else
      command ls -FBhltu              --time-style='+(%d %b %Y - %H:%M)' "$@"
   fi
}

ln() {
   if (($#)); then
      command ln "$@"
   else
      local file
      for file in * .*; do
         if [[ -h $file ]]; then
            command ls -FBAhl --color=auto --time-style="+(%d %b %y - %H:%M)" \
                       -- "$file"
         fi
      done
   fi
}

sl() {
   printf '%-8s %-17s %-3s %-4s %-4s %-10s %-12s %-s\n'\
          'Inode' 'Permissions' 'ln' 'UID' 'GID' 'Size' 'Time' 'Name'
   local args=(); (($#)) && args=("$@") || args=(*)
   stat -c "%8i %A (%4a) %3h %4u %4g %10s (%10Y) %n" -- "${args[@]}"
}

# Functions {{{1

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

_type() { (($#)) || { help type; return; }; type -a -- "$@"; }

e() { local status=$?; (($#)) && echo "$@" || echo "$status"; }

c() { [[ -t 1 ]] && command cat -n -- "$@" || command cat "$@"; }

n() { command sed -n "$1{p;q}" -- "$2"; }

diff() {
   if [[ -t 1 ]] && command -v colordiff >/dev/null 2>&1
   then         colordiff "$@"
   else command      diff "$@"
   fi
}

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

sq() { command grep -v '^[[:space:]]*#\|^[[:space:]]*$' -- "$@"; }

pa() {
   local paths
   IFS=: read -ra paths <<< "$PATH"; printf '%s\n' "${paths[@]}" | sort -u
}

x() {
   if [[ $- == *x* ]]
   then echo 'debug OFF'; set +o xtrace
   else echo 'debug ON' ; set -o xtrace
   fi
} 2>/dev/null

if ! command -v service >/dev/null 2>&1; then
   service() { /etc/init.d/"$1" "${2:-start}"; }
fi

date() {
   if (($#))
   then command date "$@"
   else command date '+%d %B [%-m] %Y, %H:%M %Z (%A)'
   fi
}

# unzip or uname
u() {
   if (($#)); then
      local arg
      for arg in "$@"; do
         if [[ -f $arg ]]; then
            case "$arg" in
               *.tar.gz  | *.tgz          ) tar zxvf      "$arg";;
               *.tar.bz2 | *.tbz2 | *.tbz ) tar jxvf      "$arg";;
                                    *.tar ) tar xvf       "$arg";;
                                    *.bz2 ) bunzip2    -- "$arg";;
                                    *.gz  ) gunzip     -- "$arg";;
                                    *.zip ) unzip      -- "$arg";;
                                    *.rar ) unrar x    -- "$arg";;
                                    *.Z   ) uncompress -- "$arg";;
                                    *.7z  ) 7z x       -- "$arg";;
               *) echo "$arg cannot be extracted!" >&2
            esac
         else
            echo "$arg is not a valid file" >&2
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
               sudo grep -iE --color "$user" /etc/{passwd,shadow}
               sort -k4 -t: /etc/group | column -ts: | command grep -iE --color "$user"
            done
      esac
   else
      sudo grep -iE --color "$USER" /etc/{passwd,shadow}
      sort -k4 -t: /etc/group | column -ts: | command grep -iE --color "$USER"
   fi
}

bak() { local arg; for arg in "$@"; do command cp -i -- "$arg" "$arg".bak; done; }

# Usage: sw file1 [file2]. If file2 is omitted, file1 is swapped with file1.bak
sw() {
   local tmpfile=$(mktemp tmp.XXXXXXXXXXX) ||
      { echo "Temporary file creation failure" >&2; return 1; }
   if (($# == 1)); then
      [[ ! -e $1.bak ]] && { echo "file $1.bak does not exist" >&2; return 2; }
      command mv -- "$1"       "$tmpfile" &&
              mv -- "$1".bak   "$1"       &&
              mv -- "$tmpfile" "$1".bak
   else
      [[ ! -e $2 ]] && { echo "file $2 does not exist" >&2; return 3; }
      command mv -- "$1"       "$tmpfile" &&
              mv -- "$2"       "$1"       &&
              mv -- "$tmpfile" "$2"
   fi
}

# todo: 'rm' not 'rm' -i + cron job ?!
bakrm() { find . -name '*~' -a ! -name '*.un~' -exec command rm -i -- {} +; }

rmi() {
   local i=0 file inodes=()
   for file in "$@"; do
      ((++i < $#)) && inodes+=(-inum "$file" -o)
   done
   inodes+=(-inum "$file")
   find . \( "${inodes[@]}" \) -exec command rm -i -- {} +
}

f() {
   if ((1 == $#))
   then find . -iname "$1"
   else find "$@"
   fi
}

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

irssi() (
   cd /var/log/irssi || exit 1
   "$HOME"/config/help/.irssi/fnotify.bash &
   command irssi
   kill %?fnotify
)

vn() {
   (($#)) && { command vim -NX -u NONE "$@"; return; }
   local opt opts=('bare vim' 'vim no .vimrc' 'vim no plugins' 'gvim no .gvimrc')
   select opt in "${opts[@]}"; do
      case "$opt" in
         "${opts[0]}") command vim -nNX  -u NONE;    break;;
         "${opts[1]}") "$my_gvim"  -nNXv -u NORC;    break;;
         "${opts[2]}") command vim -nNX  --noplugin; break;;
         "${opts[3]}") "$my_gvim"  -nN   -U NONE;    break;;
                    *) printf '\nInvalid choice!\n' >&2
      esac
   done
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
      then command grep -w -iE --color -- "$1" /etc/services
      else command grep    -iE --color -- "$1" /etc/services
      fi
   else
      if command sudo -V |
         { read -r _ _ ver; IFS=. read -r maj min _ <<<"$ver"; ((maj > 0 && min > 6)); }
      then sudo -E /bin/bash
      else sudo    /bin/bash
      fi
   fi
}

h() {
   if (($#)) || [[ ! -t 0 ]]
   then head "$@"
   else history
   fi
}

p() {
   if (($#))
   then ping -c3 "$@"
   else ps fjww --headers
   fi
}

# todo: keep?
ir() { ifdown "$1" && ifup "$1" || echo "Couldn't do it." >&2; }

hd() {
   if ((1 == $#))
   then hdparm -I -- "$1"
   else hdparm       "$@"
   fi
}

df() { command df -h "$@" | sort -k5r; }

# todo + change name?
# Fails with \n in filenames!? Try this instead:
# for file in *; do read size _ < <(du -sk "$file");...
d() {
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

rd() {
   local arg
   for arg in "$@"; do
      if [[ -d $arg ]]; then
         if read -rp "rd: remove directory '$arg'? "; then
            [[ $REPLY == @(y|yes) ]] && command rm -rf -- "$arg"
         fi
      else
         echo "$arg is not a directory" >&2
      fi
   done
}

b() {
   if   (($# == 1)); then figlet -f    smslant -- "$1"
   elif (($# == 2)); then figlet -f -- "$1"       "${@:2}"
   else figlist
   fi
}

# Programmable completion {{{1

complete -A helptopic        help # Currently, same as builtin
complete -A command          man m which whereis type ? tpye sudo
complete -A alias            alias a unalias ua
complete -A enabled          builtin
complete -A disabled         enable
complete -A export           printenv
complete -A variable         export local readonly unset use
complete -A function         function
complete -A binding          bind
complete -A user             chage chfn finger groups mail passwd slay su userdel usermod w write
complete -A hostname         dig nslookup snlookup host p ping pnig ssh shh
complete -A signal           kill k
complete -A job -P '%'       jobs j fg z disown
complete -A stopped -P '%'   bg
complete -A setopt           set o
complete -A shopt            shopt oo
complete -A file             n
complete -A directory        mkdir md rmdir rd
complete -A directory -F _cd cd

# eXclude what is not(!) matched by the pattern
complete -f -o default -X '!*.@(tar.gz|tgz|tar.bz2|tbz2|tbz|tar|bz2|gz|zip|rar|Z|7z)' u
complete -f -o default -X '!*.@(tar.gz|tgz|tar.bz2|tbz2|tbz|tar)' tar
complete -f -o default -X '!*.pl' perl   prel pl
complete -f -o default -X '!*.py' python py
complete -f -o default -X '!*.rb' ruby   rb

complete -W 'eth0 eth1 lo' ir
complete -W 'alias arrayvar binding builtin command directory disabled enabled
export file function group helptopic hostname job keyword running service
setopt shopt signal stopped user variable' cl compgen complete

# Usage: cl arg - computes a completion list for arg
cl() { column <(compgen -A "$1"); }

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

# Business specific or system dependant stuff
[[ -r $HOME/.bashrc_after ]] && . "$HOME"/.bashrc_after

# enable bash completion in interactive shells
if [[ -f /etc/profile.d/bash-completion.sh ]] && ! shopt -oq posix; then
   . /etc/profile.d/bash-completion.sh >/dev/null 2>&1
elif [[ -f /etc/bash_completion ]] && ! shopt -oq posix; then
   . /etc/bash_completion >/dev/null 2>&1
fi
