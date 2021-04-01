.PRECIOUS: %.txt %.txt.parsed

%.p.txt: %.docx transformers/docx-to-txt-pandoc.sh
	$(word 2,$^) "$<" > "$@"
%.t.txt: %.docx transformers/docx-to-txt-textutil.sh
	$(word 2,$^) "$<" > "$@"
%.txt: %.p.txt
	cp "$<" "$@"

%.txt.clean: %.txt transformers/txt-to-txt-clean.sh
	$(word 2,$^) "$<" > "$@"

%.txt.parsed: %.txt.clean
	lexparser.sh "$<" > "$@"
