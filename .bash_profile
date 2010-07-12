clear
hash fortune >/dev/null 2>&1 && fortune

# If vimx is found in $PATH, store it in the hash...
if command -v vimx >/dev/null 2>&1; then

    export MY_VIM=vimx
else
    export MY_VIM='gvim -v'
fi

export EDITOR="$MY_VIM"
export VISUAL="$MY_VIM"

# -i ignore case, -M ruler, -F quit if 1 screen, -PM long prompt
# ?test ok:else:else. The . ends the test
export LESS='-i -M -F -PM?f%f - :.?L%L lines, :.?ltL\:%lt:.?pB, %pB\% : .?e(Bottom)%t'

export FIGNORE='~'

export HISTFILE="$HOME"/.bash_history
export HISTSIZE=1000
export HISTFILESIZE=1000
export HISTCONTROL='ignoredups:erasedups'
export HISTIGNORE='..:...:-:--:1:2:3:4:a:am:b:bm:cd:cd-:cd..:cal:i:h:help:hlep:hm:bg:fg:z:c:cat:cta:df:du:en:env:hi::j:jobs:jbos:l:l.:la:ll:lr:ls:lv:ll.:lla:lc:llc:lm:llm:lu:llu:lll:msg:o:se-o:set-o:no:se+o:set+o:se:set:opt:otp:shopt:shotp:p:pw:pwd:pdw:v:vi:vim:vmi:gc:gp:gv:gvi:gvim:gvmi:su:x'

export HOSTFILE="$HOME"/.hosts

export LC_TIME=bg_BG.utf8

export CDPATH="$HOME":..:../..

# .bashrc exists and I can read it
[[ -r ~/.bashrc ]] && source ~/.bashrc

# Business specific
[[ -r ~/.bash_profile_after ]] && source ~/.bash_profile_after
