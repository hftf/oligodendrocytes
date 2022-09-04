ifeq ($(SOURCE_EXT),.md)
NATIVE_DEP_EXT=.md
NATIVE_FLAGS:=
else
NATIVE_DEP_EXT=.o.html
NATIVE_FLAGS:=-f html -t native
endif

%.native: %$(NATIVE_DEP_EXT)
	$(PANDOC) -o "$@" "$<" $(NATIVE_FLAGS)
