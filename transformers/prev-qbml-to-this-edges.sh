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
XSLT="xsltproc transformers/qbml-to-latex.xsl -"
SED='sed s/\\answer//g'
TR="tr -d '\n'"

if [ -z "$PREV" ]; then
    printf '\\nolastpackettrue\\renewcommand\lastpacketname{none}\n' > $THIS_EDGES
elif [ "$PREV" = "first" ]; then
    printf '\\firstpackettrue\\renewcommand\lastpacketname{first}\n' > $THIS_EDGES
else
    printf '\\renewcommand\lastpacketname{'                                       > $THIS_EDGES
    xpath "$PREV_QBML" "string(//packet/@name)" 2>/dev/null | $TR                >> $THIS_EDGES
    printf '}\n\\renewcommand\lastpacketone{'                                    >> $THIS_EDGES
    xpath "$PREV_QBML" "//tossup[1]/answer"  2>/dev/null | $XSLT | $SED | $TR    >> $THIS_EDGES
    printf '}\n\\renewcommand\lastpackettwenty{'                                 >> $THIS_EDGES
    xpath "$PREV_QBML" "//tossup[20]/answer" 2>/dev/null | $XSLT | $SED | $TR    >> $THIS_EDGES
    printf '}\n'                                                                 >> $THIS_EDGES
fi
