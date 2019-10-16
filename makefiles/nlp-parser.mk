.PRECIOUS: %.txt %.txt.parsed

%.txt: %.docx transformers/docx-to-txt.sh
	$(word 2,$^) "$<" > "$@"

%.txt.parsed: %.txt
	lexparser.sh "$<" > "$@"
