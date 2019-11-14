.PRECIOUS: %.x.md %.x.html

# (x refers to censoring all the alphanumeric characters with A/a)
%.x.md: %.md
	sed -e '7,$$s/Tossups/@@/' -e '7,$$s/Bonuses/==/' -e '7,$$s/[[:upper:]]/A/g' -e '7,$$s/[[:lower:][:digit:]]/a/g' -e '7,$$s/^AAAAAA:/ANSWER:/g' -e '7,$$s/^\[aa] /[10] /g' -e '7,$$s/@@/Tossups/' -e '7,$$s/==/Bonuses/' $< > $@

%.x.html: %.x.md
	pandoc -o $@ $< -f markdown -t html --template=transformers/wrap.template
#	$ echo '[Para [Str "A"],Para[LineBreak],Para[Str "A"]]' | pandoc -f native -t markdown | pandoc -f markdown -t native
#	[Para [Str "A"],Para [LineBreak,Space,Str "A"]]
	sed -Ei bak 's/<p><br \/> ​?/<p><br \/><\/p><p>/g' $@
