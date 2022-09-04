FILENAME="$1"
TEMPLATE="$2"
if [ -z "$TEMPLATE" ]; then
	TEMPLATE="transformers/template.o.html"
fi
TOURNAMENT_NAME="$3"

# TODO change space to \s
pandoc "$1" -f html+empty_paragraphs -t html+empty_paragraphs \
	--wrap=none \
	-s --template "$TEMPLATE" \
	-T "$TOURNAMENT_NAME" -M title="${FILENAME##*\/}" | \
	sed -E "s/ ((<[\/][^>]*>)+)/\1 /g" | \
	sed -E "s/((<[^/][^>]*>)+) / \1/g" | \
	perl -p -e 's/<br>\n/<\/p>\n<p>/;' \
	     -p -e 's/<p><\/p>\n//;' |
	gsed -E -e 's/<p class="p1">ANSWER/<p class="p1 answer">ANSWER/g' \
	        -e '1,/>(.* )?Bonuses/I s/<p class="p1">([A-Za-z0-9]+\. )/<p class="p1 tu">\1/g' \
	        -e '/>(.* )?Bonuses/I,$ s/<p class="p1">([A-Za-z0-9]+\. )/<p class="p1 bonus">\1/g' \
	        -e 's/>Bonuses/ id="bonuses"&/I'
