FILENAME="$1"

# TODO change space to \s
textutil -convert html "$FILENAME" -stdout \
	| sed -E "s/ ((<[\/][^>]*>)+)/\1 /g" \
	| sed -E "s/((<[^/][^>]*>)+) / \1/g"
# remove
# | sed -E 's/<\/b>( *)<span class="s[1-9]"><b>([^<]+)<\/b><\/span>( *)<b>/\1\2\3/' \
# | sed -E 's/<span class="s[1-9]"><b>([^<]+)<\/b><\/span>/\1/g'
