.PRECIOUS: %.txt %.txt.parsed

%.txt: %.docx transformers/docx-to-txt.sh
	$(word 2,$^) "$<" > "$@"

%.txt.unparsed: %.txt transformers/docx-to-txt-unparsed.sh
	$(word 2,$^) "$<" > "$@"

%.txt.parsed: %.txt.unparsed
	lexparser.sh "$<" > "$@"
