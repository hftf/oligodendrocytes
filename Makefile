.PRECIOUS: %.orig.html %.native %.md %.html %.qbml %.tex
DIR=O
PACKETS=\
	01 \
	02 \
	03 \
	04 \
	05 \
	06 \
	07 \
	08 \
	09 \
	10 \
	11 \
	E1 \
	E2 \
	E3 \
	E4
PDFS=$(patsubst %, $(DIR)/%.pdf, $(PACKETS))
#MDS=$(patsubst %, $(DIR)/%.md, $(PACKETS))

all: $(PDFS)

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

%.qbml: %.html transformers/html-to-qbml.xsl
	xsltproc --timing -o $@ transformers/html-to-qbml.xsl $<

%.tex: %.qbml transformers/qbml-to-latex.xsl transformers/fix-qbml.sh
	./transformers/fix-qbml.sh < $< > temp
	mv temp $<
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
