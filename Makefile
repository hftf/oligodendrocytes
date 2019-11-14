.SUFFIXES:
.PHONY: meta all formats most \
	answers
.PRECIOUS: %.native %.md %.md.nowrap %.o.html
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

most: $(call FORMATS,o.html) $(call FORMATS,md) $(call FORMATS,md.nowrap) $(call FORMATS,f.html)


# TODO should these depend on any packet files, or it doesn't matter because phony?
answers: transformers/answers.sh $(call FORMATS,md.nowrap)
	$< $(PACKETS_DIR)


# TODO add md.nowrap md.nowrap.bon md.nowrap.tos o.html f.html r.html txt txt.parsed x.html x.md
# basically all except doc
clean:
	cd $(PACKETS_DIR) && rm -vf *.html* *.native *.md

reset:
	./dl-gdocs.sh $(PACKETS_DIR) $(DL_GDOCS_ARGS)

$(info Making: $(MAKECMDGOALS))

# (o.html stands for original.html)
%.o.html: %.docx transformers/docx-to-o-html.sh
	$(word 2,$^) "$<" > "$@"

ifeq ($(SOURCE_EXT),.md)
NATIVE_DEP_EXT=.md
NATIVE_FLAGS:=
else
NATIVE_DEP_EXT=.o.html
NATIVE_FLAGS:=-f html -t native
endif

%.native: %$(NATIVE_DEP_EXT)
	pandoc -o "$@" "$<" $(NATIVE_FLAGS)

%.md: %.o.html
	pandoc -o "$@" "$<" -f html -t markdown

%.md.nowrap: %.o.html
	pandoc -o "$@" "$<" -f html -t markdown --no-wrap


-include makefiles/f.mk
-include makefiles/t.mk
