.SUFFIXES:
.PHONY: meta all texs pdfs formats
.PRECIOUS: %.o.html %.f.html %.native %.md %.html %.qbml %.wqbml %.edges %.tex
SHELL=bash


TOURNAMENTS_DIR=tournaments/
CACHE=_cache/
# TODO use current only if not given
CURR_FILE:=$(TOURNAMENTS_DIR)current.txt
CURR_TOURNAMENT:=$(shell cat $(CURR_FILE))
CURR_DIR:=$(TOURNAMENTS_DIR)$(CURR_TOURNAMENT)/
CURR_DIR_CACHE:=$(CURR_DIR)$(CACHE)
PACKETS_DIR:=$(CURR_DIR)packets/
DOCS_DIR:=$(PACKETS_DIR)docs/
METADATA_XSL=$(TOURNAMENTS_DIR)$(CACHE)metadata.xsl
SETTINGS_XML=$(CURR_DIR)settings.xml
$(info $(shell echo -e "\033[0;37;44m $(CURR_TOURNAMENT) \033[0m"))


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
	awk -f $(word 2,$^) $< > $@

$(CURR_DIR_CACHE)metadata.xsl: $(SETTINGS_XML) transformers/settings-to-metadata.xsl
	saxon -o:$@ $^

$(METADATA_XSL): $(CURR_DIR_CACHE)metadata.xsl
	mkdir -p $(dir $@)
	cp $< $@


%.xml: %.pxml
	pxslcc -h $< > $@

%.xsl: %.pxsl transformers/xslt2.edf
	pxslcc -hx --add=$(word 2,$^) $< > $@


PACKETS=$(wildcard $(PACKETS_DIR)*$(SOURCE_EXT))
FORMATS=$(PACKETS:$(SOURCE_EXT)=.$(1))
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
	./dl-gdocs.sh $(DOCS_DIR) $(PACKETS_DIR) $(DL_GDOCS_ARGS)

$(info Making: $(MAKECMDGOALS))

# TODO fix $@, etc. to "$@"
# (o.html stands for original.html)
%.o.html: %.docx
	textutil -convert html $< -stdout \
	| sed -E "s/ ((<[\/][^>]*>)+)/\1 /g" \
	| sed -E "s/((<[^/][^>]*>)+) / \1/g" \
	> $@

ifeq ($(SOURCE_EXT),.md)
NATIVE_DEP_EXT=.md
NATIVE_FLAGS:=
else
NATIVE_DEP_EXT=.o.html
NATIVE_FLAGS:=-f html -t native
endif

%.native: %$(NATIVE_DEP_EXT)
	pandoc -o $@ $< $(NATIVE_FLAGS)

%.md: %.o.html
	pandoc -o $@ $< -f html -t markdown

%.md.nowrap: %.o.html
	pandoc -o $@ $< -f html -t markdown --no-wrap

-include x.mk

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
