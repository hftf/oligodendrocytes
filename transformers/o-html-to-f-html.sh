FILENAME="$1"

cat transformers/top-1.html
<$FILENAME \
	sed -n '/<style/,/<\/style/p' | \
	gsed -E 's/font: ([0-9]+)\.0px/font: \10%/g'
cat transformers/top-2.html
<$FILENAME \
	perl -p -e 's/<br>\n/<\/p>\n<p>/;' \
	     -p -e 's/<p><\/p>\n//;' |
	gsed -E -e '0,/^<body>$$/d' \
	        -e 's/<p class="p1">ANSWER/<p class="p1 answer">ANSWER/g' \
	        -e '1,/>Bonuses/I s/<p class="p1">([A-Za-z0-9]+\. )/<p class="p1 tu">\1/g' \
	        -e '/>Bonuses/I,$ s/<p class="p1">([A-Za-z0-9]+\. )/<p class="p1 bonus">\1/g' \
	        -e 's/>Bonuses/ id="bonuses"&/I' \
	        -e '/^<\/body>$$/,$d'
cat transformers/bottom.html
