# [[ -w $HISTFILE ]] && tmp=$(mktemp) && awk '!($0 in a){a[$0];print}' "$HISTFILE" > "$tmp" && mv "$tmp" "$HISTFILE"

# Not sure this is correct and/or optimized.
[[ -f $HISTFILE ]] && tmp=$(mktemp) && tac "$HISTFILE" | awk '!a[$0]++' | tac > "$tmp" && mv "$tmp" "$HISTFILE"
