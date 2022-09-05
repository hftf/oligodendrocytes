PREFIX=$1

DATE=`date "+%F"`
EDITION=$DATE

shopt -s extglob
zip "$PREFIX"zips/docxs-$DATE.zip          $PREFIX!(*password).docx
zip "$PREFIX"zips/pdfs-$DATE.zip           $PREFIX!(*password).pdf
zip "$PREFIX"zips/password-pdfs-$DATE.zip  $PREFIX*.password.pdf
