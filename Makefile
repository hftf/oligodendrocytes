.SUFFIXES:
.PHONY: meta all formats most \
	check check2 answers words
.PRECIOUS: %.native %.md %.md.nowrap %.o.html %.p.o.html
SHELL=bash


TOURNAMENTS_DIR=tournaments/
CACHE=_cache/

# TODO use current only if not given
CURR_FILE:=$(TOURNAMENTS_DIR)current.txt
ifeq ($(wildcard $(CURR_FILE)),)
$(error Current tournament is not set)
endif

CURR_TOURNAMENT:=$(shell cat $(CURR_FILE))
ifeq ($(CURR_TOURNAMENT),sample)
$(error Current tournament should not be "sample")
endif

CURR_DIR:=$(TOURNAMENTS_DIR)$(CURR_TOURNAMENT)/
CURR_DIR_CACHE:=$(CURR_DIR)$(CACHE)
PACKETS_DIR:=$(CURR_DIR)packets/
SETTINGS_XML=$(CURR_DIR)settings.xml
$(info $(shell echo -e "\033[0;37;44m $(CURR_TOURNAMENT) \033[0m"))


ifneq ($(MAKECMDGOALS),clean-meta)
-include $(CURR_DIR_CACHE)vars.mk
endif

META:=$(addprefix $(CURR_DIR_CACHE),vars.mk)
meta: $(META)
clean-meta:
	rm -vf $(META)

$(CURR_DIR_CACHE)vars.mk: transformers/settings-to-vars.xsl $(SETTINGS_XML)
	xsltproc -o $@ $^


%.xml: %.pxml
	pxslcc -h "$<" > "$@"

%.xsl: %.pxsl transformers/xslt2.edf
	pxslcc -hx --add=$(word 2,$^) "$<" > "$@"


PACKETS=$(wildcard $(PACKETS_DIR)*$(SOURCE_EXT))
FORMATS=$(PACKETS:$(SOURCE_EXT)=.$(1))

formats: $(call FORMATS,$(EXT))
# usage: `make formats EXT=html`

most: $(call FORMATS,o.html) $(call FORMATS,md) $(call FORMATS,md.nowrap) $(call FORMATS,txt) $(call FORMATS,f.html)


# TODO should these depend on any packet files, or it doesn't matter because phony?
check: check-nonos.sh $(call FORMATS,md)
	./$< $(PACKETS_DIR) | cat -n
check2: check-nonos-2.sh most answers
	./$< $(PACKETS_DIR) | cat -n

# TODO split up with intermediate dependencies
answers: transformers/answers.sh $(call FORMATS,md.nowrap)
	$< $(PACKETS_DIR)

words: transformers/words.sh $(call FORMATS,w.html)
	$< $(PACKETS_DIR)


# TODO add md.nowrap md.nowrap.bon md.nowrap.tos o.html f.html r.html txt txt.parsed x.html x.md
# basically all except doc
clean:
	cd $(PACKETS_DIR) && rm -vf *.html* *.native *.md *.md.nowrap *.txt

reset:
	./dl-gdocs-drive.sh $(PACKETS_DIR) $(DL_GDOCS_ARGS)

$(info Making: $(MAKECMDGOALS))


PANDOC:=pandoc

# (o.html stands for original.html)
%.p.o.html: %.docx transformers/docx-to-o-html-pandoc.sh transformers/template.o.html
	$(word 2,$^) "$<" $(word 3,$^) "$(TOURNAMENT_NAME)" > "$@"
%.t.o.html: %.docx transformers/docx-to-o-html-textutil.sh
	$(word 2,$^) "$<" > "$@"
%.o.html: %.p.o.html
	cp "$<" "$@"

%.md: %.o.html
	$(PANDOC) -o "$@" "$<" -f html -t markdown-bracketed_spans-native_spans-smart

%.md.nowrap: %.o.html
	$(PANDOC) -o "$@" "$<" -f html -t markdown-bracketed_spans-native_spans-smart --wrap=none


-include makefiles/native.mk
-include makefiles/f.mk
-include makefiles/t.mk
