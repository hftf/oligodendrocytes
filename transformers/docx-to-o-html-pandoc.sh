FILENAME="$1"

pandoc "$FILENAME" -f docx+empty_paragraphs -t html+empty_paragraphs \
	--wrap=none
