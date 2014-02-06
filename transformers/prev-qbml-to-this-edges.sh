DIR=${1%/*}
THIS=${1%.edges}
#QBML=$THIS.qbml
THIS=${THIS##*/}
#NEXT=$(awk "/$THIS/ { if (getline); print }" order.txt)
PREV=$(awk "/$THIS/ { print (NR == 1) ? \"first\" : line; } { line = \$0 } " order.txt)
PREV_QBML=$DIR/$PREV.qbml
THIS_EDGES=$1
# echo $DIR
# echo $THIS
# echo $PREV_QBML
# echo $PREV
# echo $THIS_EDGES

# TODO fix whitepsace
#XPATH="xpath"

# xmllint --noent doesn't work with --xpath:
# $ echo "<å>å</å>" | xmllint --encode UTF-8 --noent -
# <?xml version="1.0" encoding="UTF-8"?>
# <å>å</å>
# $ echo "<å>å</å>" | xmllint --encode UTF-8 --noent --xpath / -
# <?xml version="1.0"?>
# <å>&#xE5;</å>
XPATH="xmllint --xpath"
XSLT="xsltproc transformers/qbml-to-latex.xsl -"
SED='sed s/\\answer//g'
TR="tr -d '\n'"

if [ -z "$PREV" ]; then
    printf '\\nolastpackettrue\\renewcommand\lastpacketname{none}\n' > $THIS_EDGES
elif [ "$PREV" = "first" ]; then
    printf '\\firstpackettrue\\renewcommand\lastpacketname{first}\n' > $THIS_EDGES
else
    printf '\\renewcommand\lastpacketname{'                            > $THIS_EDGES
    $XPATH "string(//packet/@name)" "$PREV_QBML" | $TR                >> $THIS_EDGES
    printf '}\n\\renewcommand\lastpacketone{'                         >> $THIS_EDGES
    $XPATH "//tossup[1]/answer"     "$PREV_QBML" | $XSLT | $SED | $TR >> $THIS_EDGES
    printf '}\n\\renewcommand\lastpackettwenty{'                      >> $THIS_EDGES
    $XPATH "//tossup[20]/answer"    "$PREV_QBML" | $XSLT | $SED | $TR >> $THIS_EDGES
    printf '}\n'                                                      >> $THIS_EDGES
fi
