FILENAME="$1"
FILENAMER1="${FILENAME##*/}"
FILENAMER="${FILENAMER1/.o./.r.}"

cat transformers/top-1.html
<$FILENAME \
	sed -n '/<style/,/<\/style/p' | \
	gsed -E 's/font: ([0-9]+)\.0px/font: \10%/g'
cat transformers/top-2.html | sed "s@FILENAMER@$FILENAMER@g"
<$FILENAME \
	gsed -E -e '0,/^<body>$$/d' \
	        -e 's/<p class="p1">ANSWER/<p class="p1 answer">ANSWER/g' \
	        -e '1,/>Bonuses/I s/<p class="p1">([0-9]+\. )/<p class="p1 tu">\1/g' \
	        -e 's/<\/body>/<script src="clipboard-polyfill.js"><\/script><script src="findAndReplaceDOMText.js"><\/script><script src="number.js"><\/script><\/body>/'
