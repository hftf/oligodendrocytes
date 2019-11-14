.PHONY: texs pdfs
.PRECIOUS: %.html %.qbml %.wqbml %.edges %.tex

TEXS:=$(call FORMATS,tex)
PDFS:=$(call FORMATS,pdf)

all: texs
texs: $(TEXS)
pdfs: $(PDFS)

clean: clean-qbml-tex

clean-qbml-tex:
	cd $(PACKETS_DIR) && rm -vf *.qbml* *.wqbml *.edges *.tex* *.aux *.log *.out *.pdf


# does not actually depend on %.md
%.html: %.native %.md transformers/wrap.template
	pandoc -o $@ $< -f native -t html --template=$(word 3,$^)

%.k.html: %.native %.md transformers/html.template
	pandoc -o $@ $< -f native -t html --template=$(word 3,$^)

%.qbml: %.html transformers/html-to-qbml.xsl transformers/fix-qbml.sh $(METADATA_XSL)
	saxon -o:$@ $< $(word 2,$^)
	$(word 3,$^) < $@ > $@.temp
	mv $@.temp $@
ifdef DIFF
	xsltproc -o $@o old/html-to-qbml.xsl $<
	$(word 3,$^) < $@o > $@o.temp
	mv $@o.temp $@o
	diff <(xmllint --format $@) <(xmllint --format $@o)
endif

%.tossup.answers: %.qbml transformers/qbml-to-answers.xsl
	saxon -o:$@ $^ type=tossup
%.bonus.answers: %.qbml transformers/qbml-to-answers.xsl
	saxon -o:$@ $^ type=bonus

%.edges: $(ORDER) transformers/prev-qbml-to-this-edges.sh
	$(word 2,$^) $@ $<

%.wqbml: %.qbml transformers/qbml-to-wqbml.xsl
	saxon -o:$@ $^

tests/qbml-to-wqbml-2.wqbml: tests/qbml-to-wqbml.qbml transformers/qbml-to-wqbml-2.xsl
	saxon -o:$@ $^

tests: tests/qbml-to-wqbml.wqbml tests/qbml-to-wqbml-2.wqbml
	diff $^

%.tex: %.qbml %.edges transformers/qbml-to-latex.xsl
	xsltproc -o $@ $(word 3,$^) $<
ifdef DIFF
	xsltproc -o $@o old/qbml-to-latex.xsl $<
	diff $@ $@o
endif

%.pdf: %.tex packet.cls
	xelatex -output-directory $(PACKETS_DIR) $< -interaction=batchmode

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
