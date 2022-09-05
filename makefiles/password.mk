PASSWORDSFILE=$(PACKETS_DIR)passwords.csv
GETPASSWORD=$(shell sed -n "s/^[^,]*,\([^,]*\),$(notdir $(1:.password.$(2)=)).*/\1/p" \
	$(PASSWORDSFILE))

%.password.pdf: %.pdf transformers/password-pdf.sh
	PASSWORD=$(call GETPASSWORD,$@,pdf)
	$(word 2,$^) $(PASSWORD) "$<" "$@"
%.password.docx: %.pdf transformers/password-docx.sh
	PASSWORD=$(call GETPASSWORD,$@,pdf)
	$(word 2,$^) $(PASSWORD) "$<" "$@"
