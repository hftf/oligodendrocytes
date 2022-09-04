FILENAME="$1"
TEMPLATE="$2"
if [ -z "$TEMPLATE" ]; then
	TEMPLATE="transformers/template.o.html"
fi

# TODO change space to \s
pandoc "$FILENAME" -f docx+empty_paragraphs -t html+empty_paragraphs \
	--wrap=none \
	-s --template "$TEMPLATE" \
	| sed -E "s/ ((<[\/][^>]*>)+)/\1 /g" \
	| sed -E "s/((<[^/][^>]*>)+) / \1/g"
