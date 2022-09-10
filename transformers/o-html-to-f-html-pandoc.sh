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
	     -p -e 's/<p><\/p>\n/<p><br><\/p>\n/;' \
	     -p -e 's/strong>/b>/g;' \
	     -p -e 's/em>/i>/g;' |
	gsed -E -e 's/<p>ANSWER/<p class="answer">ANSWER/g' \
	        -e '1,/>(.* )?Bonuses/I s/<p>([A-Za-z0-9]+\. )/<p class="tu">\1/g' \
	        -e '/>(.* )?Bonuses/I,$ s/<p>([A-Za-z0-9]+\. )/<p class="bonus">\1/g' \
	        -e 's/>Bonuses<\/p/ id="bonuses"&/I'
