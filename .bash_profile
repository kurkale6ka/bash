# XDG
[[ -z $XDG_CONFIG_HOME ]] && export XDG_CONFIG_HOME=~/.config
[[ -z   $XDG_DATA_HOME ]] && export   XDG_DATA_HOME=~/.local/share

# Repos
if [[ -z $REPOS_BASE ]]
then
   if [[ -z $SSH_CONNECTION ]]
   then
      if ! who | 'grep' -q '([0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\})'
      then
         REPOS_BASE_LINK="$(find ~ -maxdepth 1 -lname github -printf '%p\n')"
         [[ -L $REPOS_BASE_LINK ]] && REPOS_BASE="$REPOS_BASE_LINK"
      fi
   fi
   REPOS_BASE="${REPOS_BASE:-"$(cd "${BASH_SOURCE[0]%/*}/.." && pwd -P)"}"
   export REPOS_BASE="${REPOS_BASE%/}"
fi

# readline
export INPUTRC="$REPOS_BASE"/config/dotfiles/.inputrc

# Put ~/bin and REPOS_BASE in PATH
if ! grep -q ~/bin <<< "$PATH"
then
   export PATH=~/bin:"$PATH"
fi
if ! grep -q "$REPOS_BASE" <<< "$PATH"
then
   export PATH="$REPOS_BASE":"$PATH"
fi

export PYTHONSTARTUP=~/.pyrc

export LANG=en_GB.UTF-8
export LC_COLLATE=C

# Remove w permissions for group and others
# file      default: 666 (-rw-rw-rw-) => 644 (-rw-r--r--)
# directory default: 777 (drwxrwxrwx) => 755 (drwxr-xr-x)
umask 022

# Vim
if command -v nvim
then
   export EDITOR=nvim
else
   export EDITOR="vim -u $REPOS_BASE/vim/.vimrc"
fi >/dev/null 2>&1

export VISUAL="$EDITOR"

export FZF_DEFAULT_OPTS='--height 40% --layout=reverse'

# ps
export PS_PERSONALITY=bsd
export PS_FORMAT=pid,ppid,pgid,sid,tname,tpgid,stat,euser,egroup,start_time,cmd

# -i   : ignore case
# -r/R : raw control characters
# -s   : Squeeze multiple blank lines
# -W   : Highlight first new line after any forward movement
# -M   : very verbose prompt
# -PM  : customize the very verbose prompt (there is also -Ps and -Pm)
# ?letterCONTENT. - if test true display CONTENT (the dot ends the test) OR
# ?letterTRUE:FALSE.
# ex: ?L%L lines, . - if number of lines known: display %L lines,
export LESS='-i -r -s -W -M -PM?f%f - :.?L%L lines, .?ltL\:%lt:.?pB, %pB\% : .?e(Bottom)%t'
export PAGER=less

# Business specific or system dependant stuff
# test needed when ~/.profile is a link to this file but the SHELL is zsh
if [[ $SHELL == *bash ]]
then
   [[ -r $REPOS_BASE/bash/.bash_profile_after ]] && . "$REPOS_BASE"/bash/.bash_profile_after
   [[ -r $REPOS_BASE/bash/.bashrc             ]] && . "$REPOS_BASE"/bash/.bashrc
fi
