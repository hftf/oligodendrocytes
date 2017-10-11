.PRECIOUS: %.x.md %.x.html

# (x refers to censoring all the alphanumeric characters with A/a)
%.x.md: %.md
	sed -e '7,$$s/Tossups/@@/' -e '7,$$s/Bonuses/==/' -e '7,$$s/[[:upper:]]/A/g' -e '7,$$s/[[:lower:][:digit:]]/a/g' -e '7,$$s/^AAAAAA:/ANSWER:/g' -e '7,$$s/^\[aa] /[10] /g' -e '7,$$s/@@/Tossups/' -e '7,$$s/==/Bonuses/' $< > $@

%.x.html: %.x.md
	pandoc -o $@ $< -f markdown -t html --template=transformers/wrap.template
#	$ echo '[Para [Str "A"],Para[LineBreak],Para[Str "A"]]' | pandoc -f native -t markdown | pandoc -f markdown -t native
#	[Para [Str "A"],Para [LineBreak,Space,Str "A"]]
	sed -Ei bak 's/<p><br \/> ​?/<p><br \/><\/p><p>/g' $@

# (f.html stands for formatted.html, which is essentially o.html with naive substitutions)
%.f.html: %.o.html x.mk
	cat transformers/top.html > $@
	gsed -E -e '0,/^<body>$$/d' -e 's/<p class="p1">ANSWER/<p class="p1 answer">ANSWER/g' -e 's/<p class="p1">([0-9]+\. )/<p class="p1 tu">\1/g' -e 's/<\/body>/<script src="findAndReplaceDOMText.js"><\/script><script src="number.js"><\/script><\/body>/' $< >> $@
