PASSWORD=$1
PDF_FILENAME=$2
PASSWORD_PDF_FILENAME=$3

echo "Encrypting $2 to $3"
qpdf --encrypt "$PASSWORD" "$PASSWORD" 256 -- "$PDF_FILENAME" "$PASSWORD_PDF_FILENAME"
