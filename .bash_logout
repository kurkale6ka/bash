# Make sure there are no duplicates in my history file
# ----------------------------------------------------

if [[ -w $HISTFILE ]]; then

   # First, remove all leading or trailing white spaces
   sed -i '1,$s/^[[:space:]]+|[[:space:]]+$//g' "$HISTFILE"

   if tmp="$(mktemp)"; then

      # tac: we want txt1 \n txt2 \n txt1 =>         txt2 \n txt1,
      #          not txt1 \n txt2 \n txt1 => txt1 \n txt2
      #
      # awk: if not line in a => put it in, print it.
      if tac "$HISTFILE" | awk '!($0 in a){a[$0];print}' | tac > "$tmp"; then
         'mv' "$tmp" "$HISTFILE"
      fi
   fi
fi
