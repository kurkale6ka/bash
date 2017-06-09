# XDG
[[ -z $XDG_CONFIG_HOME ]] && export XDG_CONFIG_HOME=~/.config
[[ -z   $XDG_DATA_HOME ]] && export   XDG_DATA_HOME=~/.local/share

# Repos
((EUID > 0)) && REPOS_BASE=~/github
export REPOS_BASE="${REPOS_BASE%/}"

# readline
export INPUTRC="$REPOS_BASE"/config/dotfiles/.inputrc

# Put ~/bin in PATH
if ! grep ~/bin <<< "$PATH" >/dev/null
then
   export PATH=~/bin:"$PATH"
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
then nvim=nvim
else nvim=vim
fi >/dev/null 2>&1

export EDITOR="$nvim"
export VISUAL="$nvim"

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

# Needs installing x11-ssh-askpass
# TODO: fix keyboard layout issue
if [[ -n $SSH_ASKPASS && -x $(command -v keychain) ]]
then
   setxkbmap -layout gb
   eval "$(keychain --eval --agents ssh -Q --quiet id_rsa id_rsa_git)"
fi

# Business specific or system dependant stuff
[[ -r $REPOS_BASE/bash/.bash_profile_after ]] && . "$REPOS_BASE"/bash/.bash_profile_after
[[ -r $REPOS_BASE/bash/.bashrc             ]] && . "$REPOS_BASE"/bash/.bashrc
