set -e

if [ $# -ne 5 ]; then
    echo "Need 5 arguments"
    exit 0
fi

PACKETS_DIR="$1"                # packets/
GDOCS_FOLDER_ID="$2"
PACKET_FILENAME_TO_SLUG_START="$3"
PACKET_FILENAME_TO_SLUG_LENGTH="$4"
EXTENSION="$5"

# TODO figure out how to make packets folder not automatically appear in root dir of oligodendrocytes

if [ -z "$GDOCS_FOLDER_ID" ]; then
    echo "Need Google Drive folder ID."
    echo "(As of 2022-09-01, folder ID is needed instead of name.)"
    exit 0
fi

DATE=`date "+%F"`
DOCS_DIR="$PACKETS_DIR"docs/    # packets/docs/
TEMP_DOCS_DIR="$DOCS_DIR"tmp/   # packets/docs/tmp/
DATE_DOCS_DIR="$DOCS_DIR"$DATE/ # packets/docs/yyyy-mm-dd/

mkdir -p $TEMP_DOCS_DIR
mkdir -p $DATE_DOCS_DIR

if [ 1 ]; then
    echo "clearing old docs in $PACKETS_DIR, $TEMP_DOCS_DIR, $DATE_DOCS_DIR"
    rm -rf $PACKETS_DIR*.$EXTENSION $TEMP_DOCS_DIR* $DATE_DOCS_DIR*.$EXTENSION

    echo "fetching docs into $TEMP_DOCS_DIR"
    drive pull -export "$EXTENSION" -exports-dir "$TEMP_DOCS_DIR" -explicitly-export -same-exports-dir -files -verbose -id "$GDOCS_FOLDER_ID"
fi

echo
echo "changing filenames and copying into $DATE_DOCS_DIR"
for DOC in $TEMP_DOCS_DIR*; do
    OLDNAME=${DOC##*\/}
    OLDNAME=${OLDNAME%.$EXTENSION}

    # commented out 2020-03-05
    #if [ "$PACKET_FILENAME_TO_SLUG_START" -eq "0" ]; then
    #    NEWNAME=$OLDNAME
    #else
        if [ "$PACKET_FILENAME_TO_SLUG_LENGTH" -eq "0" ]; then
            NEWNAME=${OLDNAME:$PACKET_FILENAME_TO_SLUG_START}
        else
            NEWNAME=${OLDNAME:$PACKET_FILENAME_TO_SLUG_START:$PACKET_FILENAME_TO_SLUG_LENGTH}
        fi
    #fi

    NEWNAME=${NEWNAME// /_}

    if [ ! -z "$NEWNAME" ]; then
        NEWPATH=$DATE_DOCS_DIR$NEWNAME.$EXTENSION
        printf "copying %-42s → \"$NEWNAME\"\n" "\"$OLDNAME\""
        cp "$DOC" "$NEWPATH" || true
    fi
done

echo
echo "copying into $PACKETS_DIR"
cp $DATE_DOCS_DIR* $PACKETS_DIR
