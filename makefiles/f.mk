.PRECIOUS: %.f.html %.r.html

%.p.f.html: %.o.html transformers/o-html-to-f-html-pandoc.sh transformers/top-1.html transformers/top-2.html transformers/bottom.html
	$(word 2,$^) "$<" > "$@"
%.t.f.html: %.o.html transformers/o-html-to-f-html-textutil.sh transformers/top-1.html transformers/top-2.html transformers/bottom.html
	$(word 2,$^) "$<" > "$@"
%.f.html: %.p.f.html
	cp "$<" "$@"

%.r.html: %.f.html transformers/f-html-to-r-html.py transformers/htmlparser.py
	$(word 2,$^) "$<" > "$@"

HTMLS:=$(call FORMATS,w.html)
htmls: $(HTMLS)

# TODO depends on node
%.w.html: %.r.html transformers/f-html-to-w-html.js
	$(word 2,$^) "$<" > "$@"
