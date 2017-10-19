FILENAME="$1"

# TODO change space to \s
textutil -convert html $FILENAME -stdout \
	| sed -E "s/ ((<[\/][^>]*>)+)/\1 /g" \
	| sed -E "s/((<[^/][^>]*>)+) / \1/g"
