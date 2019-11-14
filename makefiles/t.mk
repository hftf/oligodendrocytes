.PRECIOUS: %.txt %.txt.parsed

%.txt: %.docx transformers/docx-to-txt.sh
	$(word 2,$^) "$<" > "$@"

%.txt.clean: %.txt transformers/txt-to-txt-clean.sh
	$(word 2,$^) "$<" > "$@"

%.txt.parsed: %.txt.clean
	lexparser.sh "$<" > "$@"
