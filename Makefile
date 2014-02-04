.PRECIOUS: %.orig.html %.native %.md %.html %.qbml %.edges %.tex
DIR=O
PACKETS=$(wildcard $(DIR)/*.docx)
PDFS=$(PACKETS:.docx=.pdf)

all: $(PDFS)

-include .deps.mk

.deps.mk: mk-deps.sh order.txt
	./mk-deps.sh > $@

%.orig.html: %.docx
	textutil -convert html $< -stdout | \
	sed "s/ \(<\/[^>]*>\)/\1 /g" | sed "s/\(<[^/][^>]*>\) / \1/g" > $@

%.native: %.orig.html
	pandoc -o $@ $< -f html -t native

%.md: %.orig.html
	pandoc -o $@ $< -f html -t markdown

# does not actually depend on %.md
%.html: %.native %.md transformers/wrap.template
	pandoc -o $@ $< -f native -t html --template=transformers/wrap.template

%.qbml: %.html transformers/html-to-qbml.xsl transformers/fix-qbml.sh
	xsltproc --timing -o $@ transformers/html-to-qbml.xsl $<
	./transformers/fix-qbml.sh < $@ > temp
	mv temp $@

%.edges: transformers/prev-qbml-to-this-edges.sh
	./transformers/prev-qbml-to-this-edges.sh $@

%.tex: %.qbml %.edges transformers/qbml-to-latex.xsl
	xsltproc --timing -o $@ transformers/qbml-to-latex.xsl $<

%.pdf: %.tex packet.cls
	xelatex -output-directory $(DIR) $< # -interaction=batchmode

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
