FILENAME="$1"

# TODO change space to \s
pandoc "$FILENAME" -f docx+empty_paragraphs -t html+empty_paragraphs -s \
	| sed -E "s/ ((<[\/][^>]*>)+)/\1 /g" \
	| sed -E "s/((<[^/][^>]*>)+) / \1/g"
