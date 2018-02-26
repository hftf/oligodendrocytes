set -e

if [ $# -ne 4 ]; then
    echo "Need 4 arguments"
    exit 0
fi

PACKETS_DIR="$1"                # packets/
GDOCS_FOLDER_NAME="$2"
PACKET_FILENAME_TO_SLUG_START="$3"
PACKET_FILENAME_TO_SLUG_LENGTH="$4"

if [ -z "$GDOCS_FOLDER_NAME" ]; then
    echo "Need Google Drive folder name"
    exit 0
fi

DATE=`date "+%F"`
DOCS_DIR="$PACKETS_DIR"docs/    # packets/docs/
TEMP_DOCS_DIR="$DOCS_DIR"tmp/   # packets/docs/tmp/
DATE_DOCS_DIR="$DOCS_DIR"$DATE/ # packets/docs/yyyy-mm-dd/

mkdir -p $TEMP_DOCS_DIR
mkdir -p $DATE_DOCS_DIR

if [ 1 ]; then
    rm -f $TEMP_DOCS_DIR*

    echo "fetching docs into $TEMP_DOCS_DIR"
    skicka download -download-google-apps-files "$GDOCS_FOLDER_NAME" "$TEMP_DOCS_DIR"
fi

echo
echo "changing filenames and copying into $DATE_DOCS_DIR"
for DOC in $TEMP_DOCS_DIR*; do
    OLDNAME=${DOC##*\/}

    if [ "${OLDNAME: -5}" == ".docx" ]; then
        echo "skipping \"$OLDNAME\": probably an imported Word doc, not a native Google Doc"
        continue
    fi

    if [ "$PACKET_FILENAME_TO_SLUG_LENGTH" -eq "0" ]; then
        NEWNAME=$OLDNAME
    else
        NEWNAME=${OLDNAME:$PACKET_FILENAME_TO_SLUG_START:$PACKET_FILENAME_TO_SLUG_LENGTH}
    fi

    NEWNAME=${NEWNAME// /_}

    if [ ! -z "$NEWNAME" ]; then
        NEWPATH=$DATE_DOCS_DIR$NEWNAME.docx
        printf "copying %-42s → \"$NEWNAME\"\n" "\"$OLDNAME\""
        cp "$DOC" "$NEWPATH" || true
    fi
done

echo
echo "copying into $PACKETS_DIR"
cp $DATE_DOCS_DIR* $PACKETS_DIR
