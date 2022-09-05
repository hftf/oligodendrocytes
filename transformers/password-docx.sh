TO_PDF_WORKFLOW="/Users/ophir/Library/Services/to pdf.workflow/"
SET_WORD_PASSWORD_WORKFLOW="/Users/ophir/Library/Services/set word password.workflow/"

PASSWORD=$1
DOCX_FILENAME=$2
PASSWORD_DOCX_FILENAME=$3

echo "Encrypting $2 to $3"
automator -D "mypassword=$PASSWORD" -D "myoutput=$PASSWORD_DOCX_FILENAME" -D "mypath=." -i "$DOCX_FILENAME" "$SET_WORD_PASSWORD_WORKFLOW"
