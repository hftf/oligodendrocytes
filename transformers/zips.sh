#source transformers/bundle-assets/password.sh

PREFIX=$1
GDOCS_FOLDER_ID="$2"

# download pdf/docx packets by exporting directly from google drive
#drive pull -export pdf  -exports-dir "$PREFIX/zips/pdf/"  -explicitly-export -same-exports-dir -files -verbose -id "$GDOCS_FOLDER_ID"
#drive pull -export docx -exports-dir "$PREFIX/zips/docx/" -explicitly-export -same-exports-dir -files -verbose -id "$GDOCS_FOLDER_ID"

passwordsfile="$PREFIX/passwords.csv"
while read line; do
	echo "$line"
	echo "id=$id password=$password file=$file name=$name"
	# if [ -z $password ]; then
	# create the pdf and password protected pdf packets (zips)
		# echo call password for each line of password.csv
	# fi
done < "$passwordsfile"

#zip $tournament-password-pdfs-$edition.zip *.password.pdf
#zip $tournament-pdfs-$edition.zip          !(*password).pdf
#zip $tournament-docxs-$edition.zip         !(*password).docx
# scp $tournament-password-pdfs-$edition.zip $host:$hostpath/$PREFIX/html/password-pdfs.zip
