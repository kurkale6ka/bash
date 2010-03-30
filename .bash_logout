# Not sure this is necessary and correct. I have already erasedups in HISTCONTROL
# [[ -f $HISTFILE ]] && tmp=$(mktemp) && tac "$HISTFILE" | awk '!a[$0]++' | tac > "$tmp" && mv "$tmp" "$HISTFILE"
