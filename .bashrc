[[ -t 1 ]] || return 1

set -o notify
shopt -s cdspell extglob nocaseglob nocasematch histappend

HISTFILE="$REPOS_BASE"/bash/.bash_history
HISTFILESIZE=11000
HISTSIZE=11000 # size allowed in memory

HISTCONTROL=ignorespace:ignoredups:erasedups
HISTIGNORE="@(?|??|???)*( |$'\t'):*( |$'\t')"
HISTTIMEFORMAT='<%d %b %H:%M>  '

FIGNORE='~:.swp:.o' # <tab> completion

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
_bld="$(tput bold || tput md)"
_udl="$(tput smul || tput us)"
_ylw="$(tput setaf 221 || tput AF 221)"
_red="$(tput setaf 9   || tput AF 9  )"
_blk="$(tput setaf 238 || tput AF 238)"
_lgrn="$_bld$(tput setaf 2 || tput AF 2)"
_lblu="$(tput setaf 69 || tput AF 69)"
_res="$(tput sgr0 || tput me)"

# Colored man pages
export LESS_TERMCAP_mb="$_lgrn" # begin blinking
export LESS_TERMCAP_md="$_lblu" # begin bold
export LESS_TERMCAP_me="$_res"  # end mode

# Stand out (reverse) - info box (yellow on blue bg)
export LESS_TERMCAP_so="$_bld$(tput setaf 3 || tput AF 3)$(tput setab 4 || tput AB 4)"
export LESS_TERMCAP_se="$(tput rmso || tput se)$_res"

# Underline
export LESS_TERMCAP_us="$_bld$_udl$(tput setaf 5 || tput AF 5)" # purple
export LESS_TERMCAP_ue="$(tput rmul || tput ue)$_res"

# Set LS_COLORS
eval "$(dircolors "$REPOS_BASE"/config/dotfiles/.dir_colors)"

## Prompts
if [[ $TERM != linux ]]
then
   ## title: \e]2; ---- \a
   _tilda=\~
   export PROMPT_COMMAND='printf "\e]2;[%s] %s\a" "${PWD/#$HOME/$_tilda}" "$HOSTNAME"'
fi

_h_color="$(tput setaf 140 || tput AF 140)" # purple for remote
if [[ -z $SSH_CONNECTION ]]
then
   if ! who | 'grep' -q '([0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\})'
   then
      _h_color="$_ylw"
   fi
fi

# PS1/2/3/4
if ((EUID == 0))
then
   PS1="\n\[$_h_color\]\H\[$_res\] \A [\[$_lblu\]\w\[$_res\]]"'$(((\j>0)) && echo \ ❭ \[$_red\]%\j\[$_res\])'"\n\[$_red\]\u\[$_res\] # "
else
   PS1="\n\[$_h_color\]\H\[$_res\] \A [\[$_lblu\]\w\[$_res\]]"'$(((\j>0)) && echo \ ❭ \[$_red\]%\j\[$_res\])'"\n\[$_ylw\]\u\[$_res\] \\$ "
fi

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

alias pg="$REPOS_BASE/scripts/pg.pl"

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
complete -A user     chage chfn finger groups mail passwd slay su userdel usermod w write
complete -A hostname dig nslookup host ping ssh

complete -W 'alias arrayvar binding builtin command directory disabled enabled
export file function group helptopic hostname job keyword running service
setopt shopt signal stopped user variable' compgen complete

# enable bash completion in non posix shells
if ! shopt -oq posix; then
   if [[ -f /etc/profile.d/bash-completion.sh ]]; then
      . /etc/profile.d/bash-completion.sh
   elif [[ -f /etc/bash_completion ]]; then
      . /etc/bash_completion
   fi >/dev/null 2>&1
fi

complete -f -o default -X '!*.pl' perl
complete -f -o default -X '!*.py' python
complete -f -o default -X '!*.rb' ruby

## (n)Vim and ed
if command -v nvim
then
   alias v=nvim
else
   alias v="vim -u $REPOS_BASE/vim/.vimrc"
fi >/dev/null 2>&1

if command -v fzf >/dev/null 2>&1
then
   # Use fuzzy (fzf) search to find a file and open it in Vim
   # https://github.com/kurkale6ka/zsh/blob/master/autoload/fuzzy/vf
   vf() {
      declare -a files

      # 1. try locate
      if (($#))
      then
         while IFS= read -r -d ''
         do
            files+=("$REPLY")
         done < <(locate -0 / | grep -zv '/\.\(git\|svn\|hg\)\(/\|$\)\|~$' | fzf --read0 -0 -1 -m -q"$*" --print0 || echo "${pipestatus[2]}")
      else
         while IFS= read -r -d ''
         do
            files+=("$REPLY")
         done < <(locate -0 / | grep -zv '/\.\(git\|svn\|hg\)\(/\|$\)\|~$' | fzf --read0 -0 -1 -m --print0 || echo "${pipestatus[2]}")
      fi

      # 2. try fzf
      if [[ -z $files || $files == 130 || $files == 1 ]]
      then
         printf "${_ylw}trying fzf${_res}...\n"
         if (($#))
         then
            while IFS= read -r -d ''
            do
               files+=("$REPLY")
            done < <(fzf -0 -1 -m -q"$*" --print0)
         else
            while IFS= read -r -d ''
            do
               files+=("$REPLY")
            done < <(fzf -0 -1 -m --print0)
         fi
      fi

      if [[ -n $files && $files != 130 && $files != 1 ]]
      then
         v -- "${files[@]}"
      fi
   }
fi

vt() { tail -n11000 "$1" | v - -c'setlocal buftype=nofile bufhidden=hide noswapfile | match | $'; }

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

## ls and echo
_ls_date_old="$(tput setaf 242 || tput AF 242)%e %b${_res}"
_ls_time_old="${_blk} %Y${_res}"

_ls_date="$(tput setaf 242 || tput AF 242)%e %b${_res}"
_ls_time="${_blk}%H:%M${_res}"

ldot() {
   local ls
   if [[ ${FUNCNAME[1]} == 'l.' ]]
   then ls=(ls -FB   --color=auto)
   else ls=(ls -FBhl --color=auto --time-style="+$_ls_date_old $_ls_time_old"$'\n'"$_ls_date $_ls_time")
   fi
   (($# == 0)) && {             "${ls[@]}" -d .[^.]* ; return 0; }
   (($# == 1)) && { (cd "$1" && "${ls[@]}" -d .[^.]*); return 0; }
   local i arg
   for arg in "$@"; do
      printf '%s:\n' "$arg"
      (cd -- "$arg" && "${ls[@]}" -d .[^.]*)
      (($# != ++i)) && echo
   done
}

# Make sure existing aliases won't prevent function definitions
unalias l. ll. lx llx ln sl 2>/dev/null

 l.() { ldot "$@"; }
ll.() { ldot "$@"; }

alias   l='command ls -FB   --color=auto'
alias  ll="command ls -FBhl --color=auto --time-style=$'+$_ls_date_old $_ls_time_old\n$_ls_date $_ls_time'"
alias  l1='command ls -FB1  --color=auto'

alias  la='command ls -FBA   --color=auto'
alias lla="command ls -FBAhl --color=auto --time-style=$'+$_ls_date_old $_ls_time_old\n$_ls_date $_ls_time'"

alias  ld='command ls -FBd   --color=auto'
alias lld="command ls -FBdhl --color=auto --time-style=$'+$_ls_date_old $_ls_time_old\n$_ls_date $_ls_time'"

alias  lm='command ls -FBtr   --color=auto'
alias llm="command ls -FBhltr --color=auto --time-style=$'+$_ls_date_old $_ls_time_old\n$_ls_date $_ls_time'"

alias  lk='command ls -FBS   --color=auto'
alias llk="command ls -FBShl --color=auto --time-style=$'+$_ls_date_old $_ls_time_old\n$_ls_date $_ls_time'"

if command -v tree
then
   alias lr="tree -FAC -I '*~|*.swp' --noreport"
else
   alias lr="command ls -FBR --color=auto --time-style=$'+$_ls_date_old $_ls_time_old\n$_ls_date $_ls_time'"
fi >/dev/null 2>&1

alias llr="command ls -FBRhl --color=auto --time-style=$'+$_ls_date_old $_ls_time_old\n$_ls_date $_ls_time'"

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
      [[ -n ${exes[@]} ]] && ls -FBhl --color=auto --time-style="+$_ls_date_old $_ls_time_old"$'\n'"$_ls_date $_ls_time" "${exes[@]}"
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
         xargs -0 'ls' -FBAhl --color=auto --time-style="+$_ls_date_old $_ls_time_old"$'\n'"$_ls_date $_ls_time" --
      fi
   fi
}

sl() {
   printf '%-8s %-17s %-3s %-4s %-4s %-10s %-12s %-s\n'\
          'Inode' 'Permissions' 'ln' 'UID' 'GID' 'Size' 'Time' 'Name'
   local args=(); (($#)) && args=("$@") || args=(*)
   stat -c "%8i %A (%4a) %3h %4u %4g %10s (%10Y) %n" -- "${args[@]}"
}

alias e=echo

## sudo
alias  sd=sudo
alias sde=sudoedit

# run a root shell
s() {
   history -a
   if sudo -E echo -n 2>/dev/null # check for -E (preserve env vars) flag
   then sudo -E bash
   else sudo bash
   fi
}

# rerun (previous) command after replacing all occurrences of old with new
sg() {
   # sg old new [number|cmd]
   fc -s "$1"="$2" "$3"
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

      # Show statistics
      if [[ $1 == -s ]]
      then
         sqlite3 "$db" 'SELECT * FROM marks ORDER BY weight DESC;' | column -t -s'|' | less
         return 0
      fi

      # Search bookmarks
      if (($# > 0))
      then
         if command -v fzf >/dev/null 2>&1
         then
            local dir="$(sqlite3 "$db" "SELECT dir FROM marks ORDER BY weight DESC;" | fzf +s -0 -1 -q"$*" || echo "${PIPESTATUS[1]}")"
         else
            # the arguments order is significant. ex: for c 1 2 3, %1%2%3% is used.
            local _patterns
            printf -v _patterns '%s%%' "$@"
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
      # Try locate,
      # only if there were no matches, not if 'Ctrl+c' (dir = 130) was used for instance
      elif ((dir == 1)) && command -v fzf >/dev/null 2>&1
      then
         if (($# > 0))
         then
            local file="$(locate -0 / | grep -zv '/\.\(git\|svn\|hg\)\(/\|$\)\|~$' | fzf --read0 -0 -1 -q"$*")"
         else
            local file="$(locate -0 / | grep -zv '/\.\(git\|svn\|hg\)\(/\|$\)\|~$' | fzf --read0 -0 -1)"
         fi
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
   local f

   for f in "$@"
   do
      if [[ ! -d $f ]]
      then
         echo "${_red}Warning!$_res $f ${_red}isn't a directory$_res" 1>&2
      else
         (($# > 1)) && ld -1 "$f"
      fi
   done

   'rm' -rf "$@"
}

complete -A directory mkdir md rmdir rd

## Safer cp/mv + inodes rm
# problem with cp/mv is I don't usually check the destination
alias cp='cp -i'

mv() {
   if (($# != 1))
   then
      command mv -i "$@"
      return
   fi

   read -rei "$1"
   command mv -- "$1" "$REPLY"
}

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
alias x='chmod u+x'
alias bx='bash -x'

alias    setuid='chmod u+s'
alias    setgid='chmod g+s'
alias setsticky='chmod  +t'

alias cg=chgrp
alias co=chown
alias cm=chmod

## Disk/partitions functions
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
alias myip='curl ipinfo.io/ip'

dig() { command dig -4 +noall +answer "${@#*//}"; }

# Security
alias il='iptables -nvL --line-numbers'
alias nn=netstat

## rsync with CVS excludes
rs() {
   rsync --no-o --no-g --delete -e'ssh -q' \
         -f".- $HOME/.gitignore"           \
         -f':- .gitignore'                 \
         -f'- .gitignore'                  \
         -f'- .git'                        \
         -f':- .hgignore'                  \
         -f'- .hgignore'                   \
         -f'- .hg'                         \
         -f'- .svn'                        \
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
   (($# == 0)) && man man && return 0
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

complete -A helptopic help m # Currently, same as builtin
complete -A command   man m which whereis type ? tpye sudo

# which-like function
_type() {
   (($#)) || { type -a -- "$FUNCNAME"; return 0; }

   if [[ $(type -a -- "$@") == *function* ]]
   then
      type -a -- "$@" | less
      return 0
   fi

   if ! type -af -- "$@" 2>/dev/null
   then
      if ! 'which' -- "$@" 2>/dev/null
      then
         whereis -b "$@"
      fi
   fi
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

# Grep, ripgrep aliases
if command -v rg >/dev/null 2>&1; then
   alias rg='rg -S --hidden -g"!.git" -g"!.svn" -g"!.hg" --ignore-file ~/.gitignore'
   alias gr=rg
   alias g=rg
else
   alias gr='grep -IRiE --exclude-dir=.git --exclude-dir=.svn --exclude-dir=.hg --color=auto --exclude="*~" --exclude tags'
   alias g='grep -iE --color=auto --exclude="*~" --exclude tags'
fi

diff() {
   if [[ -t 1 ]] && command -v colordiff >/dev/null 2>&1
   then         colordiff "$@"
   else command      diff "$@"
   fi
}

alias vd='v -d'
alias _=combine

## Misc: options and aliases
# Options
alias  a=alias
alias ua=unalias

complete -A alias alias a unalias ua

alias  o='set -o'
alias oo=shopt

complete -A setopt set   o
complete -A shopt  shopt oo

# aliases
alias parallel='parallel --no-notice'
alias msg=dmesg
alias cmd=command
alias builtins='enable -a | cut -d" " -f2 | column'

## tmux
alias tmux='tmux -2'
alias tl='tmux ls'
alias ta='tmux attach-session'

complete -W '$(tmux ls 2>/dev/null | cut -d: -f1)' tmux
complete -W "$(screen -ls 2>/dev/null | grep -E '^\s+[0-9].*\.' | awk {print\ \$1})" screen

## uname + os
alias os='tail -n99 /etc/*{release,version} 2>/dev/null | cat -s'

## Typos
alias cta=cat
alias rmp=rpm

## fzf
[[ -f ~/.fzf.bash ]] && . ~/.fzf.bash

## Business specific or system dependant stuff
[[ -r $REPOS_BASE/bash/.bashrc_after ]] && . "$REPOS_BASE"/bash/.bashrc_after

# vim: fdm=expr fde=getline(v\:lnum)=~'^##'?'>'.(matchend(getline(v\:lnum),'###*')-1)\:'='
