%.password.pdf: %.pdf transformers/password.sh
	$(word 2,$^) "$<" > "$@"
%.password.docx: %.docx transformers/password.sh
	$(word 2,$^) "$<" > "$@"
