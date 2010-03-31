# Make sure there are no duplicates in my history file.
#
# awk: if not line in a => put it in, print it.
# tac: we want txt1 \n txt2 \n txt1 =>         txt2 \n txt1,
#          not txt1 \n txt2 \n txt1 => txt1 \n txt2
if [[ -w $HISTFILE ]]; then

    if tmp=$(mktemp); then

        if tac "$HISTFILE" | awk '!($0 in a){a[$0];print}' | tac > "$tmp"
        then
            command mv "$tmp" "$HISTFILE"
        fi
    fi
fi

clear
