[[ -t 1 ]] || return

set -o notify
shopt -s cdspell extglob nocaseglob nocasematch histappend

REPOS_BASE="${REPOS_BASE:-~/github}"

HISTFILE="$REPOS_BASE"/bash/.bash_history
HISTFILESIZE=11000
HISTSIZE=11000 # size allowed in memory

HISTCONTROL=ignorespace:ignoredups:erasedups
HISTIGNORE="@(?|??|???)*( |$'\t'):*( |$'\t')"
# HISTIGNORE='@(?|??|???)*([[:space:]]):*([[:space:]])'
HISTTIMEFORMAT='<%d %b %H:%M>  '

FIGNORE='~:.swp:.o' # <tab> completion
# Equivalents:
#    * ls -B to ignore backup files (~) in listings
#    * :set wildignore+=*~,*.swp in Vim

HOSTFILE="$HOME"/.hosts # hostnames completion (same format as /etc/hosts)

_cvs=(.git .svn .hg)
printf -v cvs '%s -o -name ' "${_cvs[@]}"

## Paths
if ((EUID == 0))
then
   # Needed if running sudo -E bash vs su - (thus sourcing all root's rc files)
   PATH=/sbin:/usr/sbin:/usr/local/sbin:/root/bin:"$PATH"
fi

## Colors
# These can't reside in .profile since there is no terminal for tput
_bld="$(tput bold)"
_udl="$(tput smul)"
_ylw="$(tput setaf 221)"
_blu="$(tput setaf 4)"
_red="$(tput setaf 9)"
_lgrn="$(printf %s "$_bld"; tput setaf 2)"
_lblu="$(printf %s "$_bld"; tput setaf 4)"
_blk="$(tput setaf 238)"
_res="$(tput sgr0)"

# Colored man pages
export LESS_TERMCAP_mb="$_lgrn" # begin blinking
export LESS_TERMCAP_md="$_lblu" # begin bold
export LESS_TERMCAP_me="$_res"  # end mode

# so -> stand out - info box
export LESS_TERMCAP_so="$(printf %s "$_bld"; tput setaf 3; tput setab 4)"
# se -> stand out end
export LESS_TERMCAP_se="$(tput rmso; printf %s "$_res")"

# us -> underline start
export LESS_TERMCAP_us="$(printf %s%s "$_bld$_udl"; tput setaf 5)"
# ue -> underline end
export LESS_TERMCAP_ue="$(tput rmul; printf %s "$_res")"

# Set LS_COLORS
eval "$(dircolors "$REPOS_BASE"/config/dotfiles/.dir_colors)"

## Prompts
if [[ $TERM != linux ]]
then
   ## title: \e]2; ---- \a
   _tilda=\~
   export PROMPT_COMMAND='printf "\e]2;[%s] %s\a" "${PWD/#$HOME/$_tilda}" "${HOSTNAME%%.*}"'
fi

_gbr() {
   local gb="$(git rev-parse --abbrev-ref HEAD 2>/dev/null)"
   if [[ $gb ]]
   then echo " ${_blk}λ-${_res}$gb"
   else echo ''
   fi
}

PS1() {
   if ((EUID == 0))
   then
      PS1="\n[\A \[$_lblu\]\w\[$_res\]]\$(_gbr)"'$(((\j>0)) && echo \ ❭ \[$_red\]%\j\[$_res\])'"\n\[$_red\]\u\[$_res\]@\[$_red\]\h\[$_res\] # "
   else
      PS1="\n[\A \[$_lblu\]\w\[$_res\]]\$(_gbr)"'$(((\j>0)) && echo \ ❭ \[$_red\]%\j\[$_res\])'"\n\[$_ylw\]\u\[$_res\]@\[$_ylw\]\h\[$_res\] \\$ "
   fi
}

       PS1 # call function above
       PS2='↪ '
export PS3='Choose an entry: '
       PS4='+ '

## Processes and jobs
# memory map
pm() {
   for i in "$@"; do
      printf '%s: ' "$i"; pmap -d "$(command pgrep "$i")" | tail -n1
   done | column -t | sort -k4
}

pg() {
   (($# == 0)) || [[ $1 == -h || $1 == --help ]] && {
      cat <<- HELP
		Usage:
		  pg [-lz] pattern
		    -l: PID PPID PGID SID TTY TPGID STAT EUSER EGROUP START CMD
		    -z: squeeze! no context lines.
		HELP
      return 0
   }

   [[ $1 == -* ]] && { [[ $1 == @(-l|-z|-lz|-zl) ]] || return 1; }

   # fields
   if [[ $1 != -*l* ]]
   then
      # PID STAT EUSER EGROUP START CMD
      local fields=pid,stat,euser,egroup,start_time,cmd
   else
      local fields=pid,ppid,pgid,sid,tname,tpgid,stat,euser,egroup,start_time,cmd
   fi

   # Display headers:
   ps o "$fields" | head -n1

   # Squeeze! No context lines
   if [[ $1 == -*z* ]]
   then
      ps  axww o "$fields" | grep -v grep | grep -iE   --color=auto "${@:2}"
   elif [[ $1 == -* ]]; then
      ps faxww o "$fields" | grep -v grep | grep -iEB1 --color=auto "${@:2}"
   else
      ps faxww o "$fields" | grep -v grep | grep -iEB1 --color=auto "$@"
   fi
}

alias k=kill
alias kg='kill -- -'

complete -A signal kill k

# jobs
alias z=fg
alias -- --='fg %-'

complete -A job     -P '%' fg z jobs disown
complete -A stopped -P '%' bg

## Completion
complete -A enabled  builtin
complete -A disabled enable
complete -A export   printenv
complete -A variable export local readonly unset use
complete -A function function
complete -A binding  bind
complete -A user     chage chfn finger groups mail passwd slay su userdel \
                     usermod w write
complete -A hostname dig nslookup host ping ssh

# Usage: cl arg - computes a completion list for arg
cl() { column <(compgen -A "$1"); }

complete -W 'alias arrayvar binding builtin command directory disabled enabled
export file function group helptopic hostname job keyword running service
setopt shopt signal stopped user variable' cl compgen complete

# enable bash completion in non posix shells
if ! shopt -oq posix; then
   if [[ -f /etc/profile.d/bash-completion.sh ]]; then
      . /etc/profile.d/bash-completion.sh
   elif [[ -f /etc/bash_completion ]]; then
      . /etc/bash_completion
   fi >/dev/null 2>&1
fi

## (n)Vim and ed
if command -v nvim
then
   alias v=nvim
else
   alias v="vim -u $REPOS_BASE/vim/.vimrc"
fi >/dev/null 2>&1

# Open files found by grep in Vim
# Usage:
#   vr [-f] : filter results with fzf
vr() {
   { [[ $1 == @(-h|--help) ]] || (($# == 0)); } && {
   cat <<- 'HELP'
	Usage:
	  vr [-f] : filter results with fzf
	HELP
   return 0
   }

   if [[ $1 == -f ]] && command -v fzf >/dev/null 2>&1
   then
      v $(gr -l -- "${@:2}" . | fzf -0 -1 -m)
   else
      v $(gr -l -- "$@" .)
   fi
}

alias ed='ed -v -p:'

## ls
_ls_date_old="${_blu}%d %b${_res}"
_ls_year="${_blk} %Y${_res}"

_ls_date="${_blu}%d %b${_res}"
_ls_time="${_blk}%H:%M${_res}"

ldot() {
   local ls
   if [[ ${FUNCNAME[1]} == 'l.' ]]
   then ls=(ls -FB   --color=auto)
   else ls=(ls -FBhl --color=auto --time-style="+$_ls_date_old $_ls_year"$'\n'"$_ls_date $_ls_time")
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

alias   l='command ls -FB   --color=auto'
alias  ll="command ls -FBhl --color=auto --time-style=$'+$_ls_date_old $_ls_year\n$_ls_date $_ls_time'"
alias  l1='command ls -FB1  --color=auto'

alias  la='command ls -FBA   --color=auto'
alias lla="command ls -FBAhl --color=auto --time-style=$'+$_ls_date_old $_ls_year\n$_ls_date $_ls_time'"

alias  ld='command ls -FBd   --color=auto'
alias lld="command ls -FBdhl --color=auto --time-style=$'+$_ls_date_old $_ls_year\n$_ls_date $_ls_time'"

alias  lm='command ls -FBtr   --color=auto'
alias llm="command ls -FBhltr --color=auto --time-style=$'+$_ls_date_old $_ls_year\n$_ls_date $_ls_time'"

alias  lk='command ls -FBS   --color=auto'
alias llk="command ls -FBShl --color=auto --time-style=$'+$_ls_date_old $_ls_year\n$_ls_date $_ls_time'"

alias  lr="tree -FAC -I '*~|*.swp' --noreport"
alias llr="command ls -FBRhl --color=auto --time-style=$'+$_ls_date_old $_ls_year\n$_ls_date $_ls_time'"

_lx() {
   local exes=()
   for x in * .*
   do
      [[ -f $x && -x $x ]] && exes+=("$x")
   done
   if [[ ${FUNCNAME[1]} == 'lx' ]]
   then
      [[ -n ${exes[@]} ]] && ls -FB --color=auto "${exes[@]}"
   else
      [[ -n ${exes[@]} ]] && ls -FBhl --color=auto --time-style="+$_ls_date_old $_ls_year"$'\n'"$_ls_date $_ls_time" "${exes[@]}"
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
         xargs -0 'ls' -FBAhl --color=auto --time-style="+$_ls_date_old $_ls_year"$'\n'"$_ls_date $_ls_time" --
      fi
   fi
}

sl() {
   printf '%-8s %-17s %-3s %-4s %-4s %-10s %-12s %-s\n'\
          'Inode' 'Permissions' 'ln' 'UID' 'GID' 'Size' 'Time' 'Name'
   local args=(); (($#)) && args=("$@") || args=(*)
   stat -c "%8i %A (%4a) %3h %4u %4g %10s (%10Y) %n" -- "${args[@]}"
}

## sudo
alias  sd=sudo
alias sde=sudoedit

# s///
# sudo bash
s() {
   if (($# == 2))
   then
      # s old new [number|cmd]
      fc -s "$1"="$2" "$3"
   else
      history -a
      if sudo -E echo -n 2>/dev/null # check if -E is available
      then sudo -E /usr/bin/env bash
      else sudo    /usr/bin/env bash
      fi
   fi
}

## cd
alias -- -='cd - >/dev/null'

alias 1='cd ..'
alias 2='cd ../..'
alias 3='cd ../../..'
alias 4='cd ../../../..'
alias 5='cd ../../../../..'
alias 6='cd ../../../../../..'
alias 7='cd ../../../../../../..'
alias 8='cd ../../../../../../../..'
alias 9='cd ../../../../../../../../..'

if [[ -w $XDG_DATA_HOME/marks/marks.sqlite ]]
then
   # Fuzzy cd based on bookmarks or 'updatedb' indexed files
   # https://github.com/kurkale6ka/zsh/blob/master/README.md
   c() {
      local db="$XDG_DATA_HOME"/marks/marks.sqlite

      # Statistics
      if [[ $1 == -s ]]
      then
         sqlite3 "$db" 'SELECT * FROM marks ORDER BY weight DESC;' | column -t -s'|' | less
         return 0
      fi

      if (($# > 0))
      then
         # the arguments order is significant. ex: for c 1 2 3, %1%2%3% is used.
         local _patterns
         printf -v _patterns '%s%%' "$@"
         if command -v fzf >/dev/null 2>&1
         then
            local dir="$(sqlite3 "$db" "SELECT dir FROM marks WHERE dir LIKE '%${_patterns%\%}%' ORDER BY weight DESC;" | fzf +s -0 -1 || echo "${PIPESTATUS[1]}")"
         else
            local dir="$(sqlite3 "$db" "SELECT dir FROM marks WHERE dir LIKE '%${_patterns%\%}%' ORDER BY weight DESC LIMIT 1;")"
            [[ -z $dir ]] && dir=1
         fi
      else
         if command -v fzf >/dev/null 2>&1
         then
            local dir="$(sqlite3 "$db" "SELECT dir FROM marks ORDER BY weight DESC;" | fzf +s -0 -1 || echo "${PIPESTATUS[1]}")"
         else
            local dir="$(sqlite3 "$db" "SELECT dir FROM marks ORDER BY weight DESC LIMIT 1;")"
            [[ -z $dir ]] && dir=1
         fi
      fi

      if [[ -d $dir ]]
      then
         cd -- "$dir"
      # Only use locate if there were no matches, not if 'Ctrl+c' was used for instance
      elif ((dir == 1)) && command -v fzf >/dev/null 2>&1
      then
         # 'updatedb' indexed files
         local file="$(locate -Ai -0 "$@" | grep -z -vE '~$' | fzf --read0 -0 -1)"
         if [[ -n $file ]]
         then
            if [[ -d $file ]]
            then
               cd -- "$file"
            else
               cd -- "${file%/*}"
            fi
         fi
      fi
   }

   # Helper for c()
   update_marks() {
      local db="$XDG_DATA_HOME"/marks/marks.sqlite

      # update_marks is executed whenever PWD changes => last command 'was' a cd $_
      if [[ -d $_ ]]
      then
         local _cwd="$_"
      else
         local _cwd="$PWD"
      fi

      # Get weight for the current directory
      local weight="$(sqlite3 "$db" "SELECT weight FROM marks WHERE dir = '$_cwd';")"

      if [[ -n $weight ]]
      then
         ((weight++))
      else
         weight=1
      fi

      sqlite3 "$db" "INSERT or REPLACE into marks (dir, weight) values ('$_cwd', $weight);"
   }

   cd() { builtin cd "$@" && update_marks; }
fi

if command -v fzf >/dev/null 2>&1
then
   # Fuzzy cd under the current directory
   # usage cdf [pattern]
   cdf() {
      if (($#))
      then
         local _patterns
         printf -v _patterns '%s*' "$@"

         local dir="$(find . -xdev \( -name ${cvs% -o -name } \) -prune -o -type d -ipath "*$_patterns" -printf '%P\0' | fzf --read0 -0 -1 +m)"
      else
         local dir="$(find . -xdev \( -name ${cvs% -o -name } \) -prune -o -type d -printf '%P\0' | fzf --read0 -0 -1 +m)"
      fi

      [[ -d $dir ]] && cd -- "$dir"
   }
fi

## File system operations
alias to=touch

alias pw='pwd -P'
alias md='mkdir -p'

rd() {
   printf 'rd: remove directory ‘%s’?\n' "$@"
   read -p '(y/n) '
   [[ $REPLY == @(y|yes) ]] && 'rm' -r -- "$@"
}

complete -A directory mkdir md rmdir rd

## Safer cp/mv + inodes rm
# problem with these is I don't usually check the destination
alias cp='cp -i'
alias mv='mv -i'

# Delete based on inodes (use ls -li first)
rmi() {
   (($#)) || return 1
   local inode inodes=()
   # skip the last inode
   for inode in "${@:1:$#-1}"; do
      inodes+=(-inum "$inode" -o)
   done
   # last inode
   inodes+=(-inum "${@:$#}")
   # -inum 38 -o -inum 73
   find . -xdev \( "${inodes[@]}" \) -exec rm -i -- {} +
}

## Permissions + debug
x() {
   (($#)) && { chmod u+x -- "$@"; return; }

   if [[ $- == *x* ]]
   then echo 'debug OFF'; set +o xtrace
   else echo 'debug ON' ; set -o xtrace
   fi
} 2>/dev/null

alias bx='bash -x'

alias    setuid='chmod u+s'
alias    setgid='chmod g+s'
alias setsticky='chmod  +t'

alias cg=chgrp
alias co=chown
alias cm=chmod

## Disk/partitions functions
df() { command df -hT "$@" | sort -k6r; }

# Display largest files/directories
# ds
# ds -[fdt]
ds() {
   [[ $1 == -h || $1 == --help ]] && {
      cat <<- HELP
		Usage:
		ds
		ds -[fdt] (files, directories, total)
		HELP
      return 0
   }

   # Files
   if (($# == 0)) || [[ -d $1 ]] || { [[ $1 == -f ]] && [[ -d $2 || -z $2 ]]; }
   then
      if [[ $1 != -f ]]
      then
         local start="${1:-.}"
      else
         local start="${2:-.}"
      fi

      local file
      local files=()
      while read -r _ file
      do
         files+=("$file")
      done < <(find "$start" -xdev \( -name ${cvs% -o -name } -o -path '*vendor/bundle' -o -path '*shared/bundle' \) -prune -o -type f -printf '%p\0' | xargs -0 du -h | sort -hr | head -n15)

      if [[ -n $files ]]
      then
         llk --color -- "${files[@]#./}" | tee /tmp/ds_files
      else
         return 1
      fi
   fi

   # Directories
   if (($# == 0)) || [[ -d $1 ]] || { [[ $1 == -d ]] && [[ -d $2 || -z $2 ]]; }
   then
      if [[ $1 != -d ]]
      then
         local start="${1:-.}"
      else
         local start="${2:-.}"
      fi

      { (($# == 0)) || [[ -d $1 ]]; } && echo

      local size folder
      while read -r size folder
      do
         echo -n "$size "
         ls -d --color -- "${folder#./}"
      done < <(du -xh "$start" | sort -hr | head -n15) | tee /tmp/ds_dirs
   fi

   # Folder total
   if [[ $1 == -t ]] && [[ -d $2 || -z $2 ]]
   then
      du -sxh --time --time-style=+'%d-%b-%y %H:%M' "${2:-.}"
   fi
}

hd() { if ((1 == $#)); then hdparm -I -- "$1"; else hdparm "$@"; fi; }

mn() {
   if (($#))
   then mount "$@"
   else mount | cut -d" " -f1,3,5,6 | column -t
   fi
}

alias umn=umount
alias fu='sudo fuser -mv'

## Networking
alias myip='curl icanhazip.com'

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

# Security
alias il='iptables -nvL --line-numbers'
alias nn=netstat

## rsync with CVS excludes
rs() {
   rsync --no-o --no-g --delete-excluded -e'ssh -q' \
         -f".- $HOME/.gitignore"                    \
         -f':- .gitignore'                          \
         -f'- .gitignore'                           \
         -f'- .git'                                 \
         -f':- .hgignore'                           \
         -f'- .hgignore'                            \
         -f'- .hg'                                  \
         -f'- .svn'                                 \
         "$@"
}

## Head/tail + cat-like functions
alias h=head

alias t=tail
alias tf='tail -f -n0'

alias cn='cat -n'

# Display the first 98 lines of all (or filtered) files in . Ex: catall .ba
catall() {
   (($#)) && local filter=(-iname "$1*")
   find . -maxdepth 1 "${filter[@]}" ! -name '*~' -type f -print0 |
   xargs -0 file | grep text | cut -d: -f1 | cut -c3- | xargs head -n98 |
   v -c "se fdl=0 fdm=expr fde=getline(v\:lnum)=~'==>'?'>1'\:'='" -
}

# Print nth line in a file: n 11 /my/file
n() { command sed -n "$1{p;q}" -- "$2"; }

# Display non-empty lines in a file
sq() { command grep -v '^[[:space:]]*#\|^[[:space:]]*$' -- "$@"; }

# Cleaner PATH display
pa() { awk '!_[$0]++' <<< "${PATH//:/$'\n'}"; }

## Help
m() {
   (($# == 0)) && man man && return
   man "$@"
   local topic
   for topic in "$@"
   do
      if [[ $(type -t "$topic" 2>/dev/null) == builtin ]]
      then
         echo "${_red}see also${_res}: help $topic"
      fi
   done
}

alias mm='man -k'

mg() { man git-"${1:-help}"; }

complete -A helptopic help m # Currently, same as builtin
complete -A command   man m which whereis type ? tpye sudo

# which-like function
_type() {
   (($#)) || { type -a -- "$FUNCNAME"; return; }

   echo "${_bld}type -a (exe, alias, builtin, func):$_res"
   type -a -- "$@" 2>/dev/null
   echo

   echo "${_bld}whereis -b (bin):$_res"
   whereis -b "$@"
   echo

   echo "${_bld}file -L (deref):$_res"
   local f
   for f in "$@"
   do
      file -L "$(type -P -- "$f")"
   done
}

alias ?=_type

## Display /etc/passwd, ..group and ..shadow with some formatting
db() {
   local options[0]='/etc/passwd'
         options[1]='/etc/group'
         options[2]='/etc/shadow'

   select choice in "${options[@]}"; do

      case "$choice" in

         "${options[0]}")
            header=LOGIN:PASSWORD:UID:GID:GECOS:HOME:SHELL
            sort -k7 -t: /etc/passwd | command sed -e "1i$header" -e 's/::/:-:/g' |\
               column -ts:
            break;;

         "${options[1]}")
            header=GROUP:PASSWORD:GID:USERS
            sort -k4 -t: /etc/group | command sed "1i$header" | column -ts:
            break;;

         "${options[2]}")
            header=LOGIN:PASSWORD:LAST:MIN:MAX:WARN:INACTIVITY:EXPIRATION:RESERVED
            sudo sort -k2 -t: /etc/shadow |\
               awk -F: '{print $1":"substr($2,1,3)":"$3":"$4":"$5":"$6":"$7":"$8":"$9}' |\
               command sed -e "1i$header" -e 's/::/:-:/g' | column -ts:
            break;;
      esac
      echo '*** Wrong choice ***'
   done
}

## Find stuff and diffs
f() {
   if (($# == 1))
   then
      find . -xdev \( -name ${cvs% -o -name } \) -prune -o -type f -iname "*$1*" ! -name '*~' -printf '%M %u %g %P\n'
   elif (($# == 0)) && command -v fzf >/dev/null 2>&1
   then
      find . -xdev \( -name ${cvs% -o -name } \) -prune -o -type f ! -name '*~' -printf '%P\0' | fzf --read0 -0 -1
   fi
}

alias lo='command locate -i'
alias ldapsearch='ldapsearch -x -LLL'

# Grep or silver searcher aliases
if command -v ag >/dev/null 2>&1; then
   alias ag='ag -S --hidden --ignore=.git --ignore=.svn --ignore=.hg --color-line-number="00;32" --color-path="00;35" --color-match="01;31"'
   alias gr=ag
   alias g=ag
else
   alias g='command grep -iE --color=auto --exclude="*~" --exclude tags'
   alias gr='command grep -IriE --exclude-dir=.git --exclude-dir=.svn --exclude-dir=.hg --color=auto --exclude="*~" --exclude tags'
fi

diff() {
   if [[ -t 1 ]] && command -v colordiff >/dev/null 2>&1
   then         colordiff "$@"
   else command      diff "$@"
   fi
}

alias _=combine

## Misc: options, app aliases, rc(), b(), e()
# Options
alias  a=alias
alias ua=unalias

complete -A alias alias a unalias ua

alias  o='set -o'
alias oo=shopt

complete -A setopt set   o
complete -A shopt  shopt oo

# Application aliases
alias open=xdg-open
alias weechat='TERM=xterm-256color weechat'
alias wgetpaste='wgetpaste -s dpaste -n kurkale6ka -Ct'
alias parallel='parallel --no-notice'
alias bc='bc -ql'

# More aliases
alias msg=dmesg
alias cmd=command
alias builtins='enable -a | cut -d" " -f2  | column'
alias hg='history | command grep -iE --color=auto'

alias pl=perl
alias py=python
alias rb=irb

complete -f -o default -X '!*.pl' perl   prel pl
complete -f -o default -X '!*.py' python py
complete -f -o default -X '!*.rb' ruby   rb

# rbenv: run multiple versions of ruby side-by-side
command -v rbenv >/dev/null 2>&1 && eval "$(rbenv init -)"

# Helper for creating a minimal .inputrc file
rc() {
   local inputrc="printf '%s\n' "
         inputrc+="'\"\e[A\": history-search-backward' "
         inputrc+="'\"\e[B\": history-search-forward' >> $HOME/.inputrc"
   xclip -f <<< "$inputrc"
}

# Echo
e() { local status=$?; (($#)) && echo "$@" || echo "$status"; }

## Git
alias gc='git commit -v'
alias gp='git push origin master'
alias gs='git status -sb'
alias go='git checkout'
alias gm='git checkout master'
alias ga='git add'
alias gb='git branch'
alias gd='git diff --word-diff=color'
alias gf='git fetch'
alias gl='git log --oneline --decorate'
alias gll='git log -U1 --word-diff=color' # -U1: 1 line of context (-p implied)

## tmux
alias tl='tmux ls'
alias ta='tmux attach-session'

complete -W '$(tmux ls 2>/dev/null | cut -d: -f1)' tmux
complete -W "$(screen -ls 2>/dev/null | grep -E '^\s+[0-9].*\.' | awk {print\ \$1})" screen

## Date
date() {
   if (($#))
   then command date "$@"
   else command date '+%A %d %B %Y, %H:%M %Z (%d/%m/%Y)'
   fi
}

## uname + os
u() {
   uname -r
   echo "$(uname -mpi) (machine, proc, platform)"
}

alias os='tail -n99 /etc/*{release,version} 2>/dev/null | cat -s'

## Backup functions and aliases
b() {
   (($#)) || { echo 'Usage: bak {file} ...' 1>&2; return 1; }
   local arg
   for arg in "$@"
   do
      command cp -i -- "$arg" "$arg".bak
   done
}

# Usage: sw file [file.bak]. file.bak is assumed by default so it can be omitted
bs() {
   if [[ $1 == -@(h|-h)* ]] || (($# != 1 && $# != 2)); then
      info='Usage: sw file [file.bak]'
      if (($#))
      then echo "$info"    ; return 0
      else echo "$info" >&2; return 1
      fi
   fi
   file1="$1"
   if (($# == 1))
   then file2="$1".bak
   else file2="$2"
   fi
   if [[ -e $file1 && -e $file2 ]]
   then
      local tmpfile=$(mktemp)
      if [[ $tmpfile ]]
      then
         'mv' -- "$file1"   "$tmpfile" &&
         'mv' -- "$file2"   "$file1"   &&
         'mv' -- "$tmpfile" "$file2"
      fi
   else
      head -n2 "$file1" "$file2" # to get an error message
   fi
}

# Usage:
#   bclean    : list backup~ files
#   bclean -d : delete
#   bclean -a : show all backup~ files on the system
#
# Note: I exclude vim undo files - .*.un~
bclean() {
   # Show backup~ files under current directory
   (($# == 0)) && {
      find . -xdev -type f \( -name '*~' -o -name '.*~' \) ! -name '*.un~' ! -name '.*.un~' -printf '%M %u %g %P\n'
      return 0
   }

   case $1 in
      -d)
         find . -xdev -type f \( -name '*~' -o -name '.*~' \) ! -name '*.un~' ! -name '.*.un~' -delete ;;
      -a)
         if command -v fzf >/dev/null 2>&1
         then
            locate -0br '~$' | fzf --read0 -0 -1
         else
            locate -br '~$' | less
         fi
         ;;
      -h|--help)
         cat <<- 'HELP'
			Usage:
			  bclean    (list backup~ files)
			  bclean -d (delete)
			  bclean -a (list all backup~ files on the system)
			HELP
         ;;
      *) echo 'Unknown option. Use -h for help' 1>&2 ;;
   esac
}

alias dump='dump -u'

## Typos
alias cta=cat
alias rmp=rpm

## fzf
[[ -f ~/.fzf.bash ]] && . ~/.fzf.bash

## Business specific or system dependant stuff
[[ -r $REPOS_BASE/bash/.bashrc_after ]] && . "$REPOS_BASE"/bash/.bashrc_after

# vim: fdm=expr fde=getline(v\:lnum)=~'^##'?'>'.(matchend(getline(v\:lnum),'###*')-1)\:'='
