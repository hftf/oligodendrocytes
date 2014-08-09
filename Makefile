.PRECIOUS: %.o.html %.native %.md %.html %.qbml %.wqbml %.edges %.tex
SHELL=bash


TOURNAMENTS_DIR=tournaments/
CACHE=_cache/
PACKETS=packets/
CURR_FILE:=$(TOURNAMENTS_DIR)current.txt
CURR_DIR:=$(TOURNAMENTS_DIR)$(shell cat $(CURR_FILE))/
CURR_DIR_CACHE:=$(CURR_DIR)$(CACHE)
PACKETS_DIR:=$(CURR_DIR)$(PACKETS)
METADATA_XSL=$(TOURNAMENTS_DIR)$(CACHE)metadata.xsl
SETTINGS_XML=$(CURR_DIR)settings.xml


ifneq ($(MAKECMDGOALS),clean-meta)
-include $(CURR_DIR_CACHE)vars.mk
endif

META:=$(addprefix $(CURR_DIR_CACHE),vars.mk deps.mk metadata.xsl) $(METADATA_XSL)
meta: $(META)
clean-meta:
	rm -vf $(META)

$(CURR_DIR_CACHE)vars.mk: transformers/settings-to-vars.xsl $(SETTINGS_XML)
	xsltproc -o $@ $^
	echo "-include $(CURR_DIR_CACHE)deps.mk" >> $@

$(CURR_DIR_CACHE)deps.mk: $(ORDER) mk-deps.awk $(CURR_DIR_CACHE)vars.mk
	awk -f mk-deps.awk $< > $@

$(CURR_DIR_CACHE)metadata.xsl: $(SETTINGS_XML) transformers/settings-to-metadata.xsl
	saxon -o:$@ $^

$(METADATA_XSL): $(CURR_DIR_CACHE)metadata.xsl
	mkdir -p $(dir $@)
	cp $< $@


%.xml: %.pxml
	pxslcc -h $< > $@

%.xsl: %.pxsl transformers/xslt2.edf
	pxslcc -hx --add=transformers/xslt2.edf $< > $@


PACKETS=$(wildcard $(PACKETS_DIR)*.docx)
FORMATS=$(PACKETS:.docx=.$(1))
TEXS:=$(call FORMATS,tex)
PDFS:=$(call FORMATS,pdf)

all: texs
texs: $(TEXS)
pdfs: $(PDFS)
formats: $(call FORMATS,$(EXT))
# usage: `make formats EXT=html`


clean:
	cd $(PACKETS_DIR) && rm -vf *.html* *.native *.md *.qbml* *.wqbml *.edges *.tex* *.aux *.log *.out *.pdf

reset:
	-rm $(PACKETS_DIR)*.docx
	./dl-gdocs.sh $(PACKETS_DIR) $(DL_GDOCS_ARGS)


%.o.html: %.docx
	textutil -convert html $< -stdout | \
	sed "s/ \(<\/[^>]*>\)/\1 /g" | sed "s/\(<[^/][^>]*>\) / \1/g" > $@

%.native: %.o.html
	pandoc -o $@ $< -f html -t native

%.md: %.o.html
	pandoc -o $@ $< -f html -t markdown

%.md.nowrap: %.o.html
	pandoc -o $@ $< -f html -t markdown --no-wrap

-include x.mk

# does not actually depend on %.md
%.html: %.native %.md transformers/wrap.template
	pandoc -o $@ $< -f native -t html --template=transformers/wrap.template

%.qbml: %.html transformers/html-to-qbml.xsl transformers/fix-qbml.sh $(METADATA_XSL)
	xsltproc -o $@ transformers/html-to-qbml.xsl $<
	./transformers/fix-qbml.sh < $@ > $@.temp
	mv $@.temp $@
ifdef DIFF
	xsltproc -o $@o         old/html-to-qbml.xsl $<
	./transformers/fix-qbml.sh < $@o > $@o.temp
	mv $@o.temp $@o
	diff <(xmllint --format $@) <(xmllint --format $@o)
endif

%.edges: $(ORDER) transformers/prev-qbml-to-this-edges.sh
	./transformers/prev-qbml-to-this-edges.sh $@ $<

%.wqbml: %.qbml transformers/qbml-to-wqbml.xsl
	saxon -o:$@ $^

tests/qbml-to-wqbml.wqbml: tests/qbml-to-wqbml.qbml transformers/qbml-to-wqbml.xsl
	saxon -o:$@ $^

%.tex: %.wqbml %.edges transformers/qbml-to-latex.xsl
	xsltproc -o $@ transformers/qbml-to-latex.xsl $<
ifdef DIFF
	xsltproc -o $@o         old/qbml-to-latex.xsl $<
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
