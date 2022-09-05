PASSWORDSFILE=$(PACKETS_DIR)passwords.csv
GETPASSWORD=$(shell sed -n "s/^[^,]*,\([^,]*\),$(notdir $(1:.password.$(2)=)).*/\1/p" \
	$(PASSWORDSFILE))

%.password.pdf:  %.pdf transformers/password-pdf.sh
	$(word 2,$^) "$(call GETPASSWORD,$@,pdf)"  "$<" "$@"
%.password.docx: %.docx transformers/password-docx.sh
	$(word 2,$^) "$(call GETPASSWORD,$@,docx)" "$<" "$@"
