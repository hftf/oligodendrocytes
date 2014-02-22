.PRECIOUS: %.o.html %.native %.md %.html %.qbml %.wqbml %.edges %.tex
DIR=O
PACKETS=$(wildcard $(DIR)/*.docx)
PDFS=$(PACKETS:.docx=.pdf)

all: $(PDFS)

-include .deps.mk

.deps.mk: mk-deps.awk order.txt
	awk -f mk-deps.awk order.txt > $@

%.o.html: %.docx
	textutil -convert html $< -stdout | \
	sed "s/ \(<\/[^>]*>\)/\1 /g" | sed "s/\(<[^/][^>]*>\) / \1/g" > $@

%.native: %.o.html
	pandoc -o $@ $< -f html -t native

%.md: %.o.html
	pandoc -o $@ $< -f html -t markdown

-include x.mk

# does not actually depend on %.md
%.html: %.native %.md transformers/wrap.template
	pandoc -o $@ $< -f native -t html --template=transformers/wrap.template

%.qbml: %.html transformers/html-to-qbml.xsl transformers/fix-qbml.sh
	xsltproc -o $@ transformers/html-to-qbml.xsl $<
	./transformers/fix-qbml.sh < $@ > $@.temp
	mv $@.temp $@

%.edges: transformers/prev-qbml-to-this-edges.sh
	./transformers/prev-qbml-to-this-edges.sh $@

%.xsl: %.pxsl transformers/xslt2.edf
	pxslcc -hx --add=transformers/xslt2.edf $< > $@

%.wqbml: %.qbml transformers/qbml-to-wqbml.xsl
	saxon -o:$@ $< transformers/qbml-to-wqbml.xsl

%.tex: %.wqbml %.edges transformers/qbml-to-latex.xsl
	xsltproc -o $@ transformers/qbml-to-latex.xsl $<

%.pdf: %.tex packet.cls
	xelatex -output-directory $(DIR) $< -interaction=batchmode

# %.tex: %.md packet.template
# 	pandoc \
# 	$<				\
# 	-o $@				\
# 	--smart				\
# 	--no-wrap			\
# 	-f markdown			\
# 	-t latex			\
# 	--latex-engine=xelatex		\
# 	--standalone			\
# 	--template=packet.template
