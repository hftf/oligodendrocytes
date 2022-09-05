TO_PDF_WORKFLOW="/Users/ophir/Library/Services/to pdf.workflow/"
SET_WORD_PASSWORD_WORKFLOW="/Users/ophir/Library/Services/set word password.workflow/"

convert_docxs_to_pdfs() {
	echo "Converting docxs to pdfs"
	automator -i "$PWD" "$TO_PDF_WORKFLOW"
}

copy_pdf_with_password() {
	PASSWORD=$1
	PDF_FILENAME=$2
	PASSWORD_PDF_FILENAME=$3
	echo "Encrypting $2 to $3"
	qpdf --encrypt "$PASSWORD" "$PASSWORD" 40 -- "$PDF_FILENAME" "$PASSWORD_PDF_FILENAME"
}

set_docx_password() {
	PASSWORD=$1
	DOCX_FILENAME=$2
	PASSWORD_DOCX_FILENAME=$3
	echo "Encrypting $2 to $3"
	automator -D "mypassword=$PASSWORD" -D "myoutput=$PASSWORD_DOCX_FILENAME" -D "mypath=." -i "$DOCX_FILENAME" "$SET_WORD_PASSWORD_WORKFLOW"
}

set_both_passwords() {
	PASSWORD=$1
	PREFIX=$2

	PDF_FILENAME="$PREFIX.pdf"
	PASSWORD_PDF_FILENAME="$PREFIX.password.pdf"
	DOCX_FILENAME="$PREFIX.docx"
	PASSWORD_DOCX_FILENAME="$PREFIX.password.docx"

	copy_pdf_with_password "$PASSWORD" "$PDF_FILENAME" "$PASSWORD_PDF_FILENAME"
	set_docx_password "$PASSWORD" "$DOCX_FILENAME" "$PASSWORD_DOCX_FILENAME"
}
exit

# docx
convert_docxs_to_pdfs
echo

# docx pdf
set_both_passwords alyabyev "01"
set_both_passwords bacewicz "02"
set_both_passwords chausson "03"
set_both_passwords dohnanyi "04"
set_both_passwords ernesaks "05"
set_both_passwords feynberg "06"
set_both_passwords goossens "07"
set_both_passwords hisaishi "08"
set_both_passwords isserlis "09"
set_both_passwords jurowski "10"
set_both_passwords kapustin "11"
set_both_passwords lyapunov "12"
set_both_passwords messager "13"
set_both_passwords nazareth "14"
set_both_passwords ornstein "15"
echo

# docx docx-password pdf pdf-password
mv *.password.docx ../docx-password/
mv *.password.pdf ../pdf-password/
mv *.pdf ../pdf/
