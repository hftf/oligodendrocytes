DIR=${1%/*}
THIS_EDGES=$1
THIS=${1%.edges}
THIS=${THIS##*/}
[[ $THIS =~ \..* ]]
INFIX=$BASH_REMATCH
THIS=${THIS%.*}
ORDER=$2
#NEXT=$(awk "/$THIS/ { if (getline); print }" order.txt)
PREV=$(awk "/$THIS/ { print (NR == 1) ? \"first\" : line; } { line = \$0 } " $ORDER)
PREV_QBML=$DIR/$PREV$INFIX.qbml
# echo $THIS_EDGES      O/01.edges   O/01.x.edges
# echo $DIR             O            O
# echo $THIS              01           01
# echo $INFIX                            .x
# echo $PREV_QBML       O/11.qbml    O/11.x.qbml
# echo $PREV              11           11

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
