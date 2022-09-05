source transformers/bundle-assets/password.sh

PREFIX=$1
GDOCS_FOLDER_ID="$2"
if [ -z "$GDOCS_FOLDER_ID" ]; then
    echo "Need Google Drive folder ID."
    echo "(As of 2022-09-01, folder ID is needed instead of name.)"
    exit 0
fi

# download pdf/docx packets by exporting directly from google drive
# drive pull -export pdf  -exports-dir "$PREFIX/zips/pdf/"  -explicitly-export -same-exports-dir -files -verbose -id "$GDOCS_FOLDER_ID"
# drive pull -export docx -exports-dir "$PREFIX/zips/docx/" -explicitly-export -same-exports-dir -files -verbose -id "$GDOCS_FOLDER_ID"

echo 1
set_both_passwords asdf "$PREFIX/zips/pdf/A"
echo 3
exit

# TODO: deal with underscores in .w.html filenames (in passwords.csv) when spaces in .pdf
passwordsfile="$PREFIX/passwords.csv"
<"$passwordsfile" awk 'BEGIN{IFS=",";OFS="|";FPAT="([^,]*)|(\"[^\"]+\")"}{$1=$1;gsub(/"/,"",$3)}1' | \
while IFS="|" read id password file name; do
	echo "id=$id password=$password file=$file name=$name"
	if [ "$id" != "id" ] && [ -n "$password" ]; then
		# create the pdf and password protected pdf packets (zips)
		echo set_both_passwords "$password" "${file%%.*}"
	fi
done

#zip $tournament-password-pdfs-$edition.zip *.password.pdf
#zip $tournament-pdfs-$edition.zip          !(*password).pdf
#zip $tournament-docxs-$edition.zip         !(*password).docx
# scp $tournament-password-pdfs-$edition.zip $host:$hostpath/$PREFIX/html/password-pdfs.zip
