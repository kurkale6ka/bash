export REPOS_BASE=~/repos

if [[ -z $XDG_CONFIG_HOME ]]
then
    export XDG_CONFIG_HOME=~/.config
    export XDG_DATA_HOME=~/.local/share
fi

mkdir -p "$XDG_CONFIG_HOME"
mkdir -p "$XDG_DATA_HOME"

export MANWIDTH=90

# readline
export INPUTRC="$REPOS_BASE"/github/config/dotfiles/.inputrc

# Put ~/bin in PATH
if ! grep -q ~/bin <<< "$PATH"
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
then
   export EDITOR=nvim
else
   export EDITOR="vim -u $REPOS_BASE/github/vim/.vimrc"
fi >/dev/null 2>&1

export VISUAL="$EDITOR"

# Perl
export PERLDOC_SRC_PAGER="$EDITOR"

# fzf
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse'

if command -v fd
then
   export FZF_DEFAULT_COMMAND='fd --strip-cwd-prefix -tf -up -E.git -E"*~"'
   export  FZF_CTRL_T_COMMAND='fd --strip-cwd-prefix     -up -E.git -E"*~"'
   export   FZF_ALT_C_COMMAND='fd --strip-cwd-prefix -td -u  -E.git -E"*~"'
fi >/dev/null 2>&1

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

# Local bash_profile
[[ -r $REPOS_BASE/github/bash/.bash_profile_after ]] && . "$REPOS_BASE"/github/bash/.bash_profile_after
. "$REPOS_BASE"/github/bash/.bashrc
