PREFIX=$1
EXT=.md.nowrap

# split packets into Tossups and Bonuses
for i in ${PREFIX}*${EXT}; do
gsed    -E -e '/^Bonuses/Iq'   $i > $i.tos
gsed -n -E -e '/^Bonuses/I,$p' $i > $i.bon
done

LIMIT=""
C_1a_Q_NUM() { ack -H --output='$1'      '^(?:\xe2\x80\x8b|\W*)(\d+)\. ' $LIMIT "$@"; }
C_1b_P_LET() { ack    --output=$'$1\t$2' '/([^\W_]+)[^\s/:]+:\d+:(\d+)$'            ; }
C_2a_ACTAG() { ack -h --output=$'$1\t$2' '\\?<(?:(.*?), )?(.*?)\\?>'            "$@"; }
R_3a_ANSLN='^ ?ANSWER: (.*?)(?: \\<| \[|$)'
C_3a_ANSLN() { ack -h --output='$1'      "$R_3a_ANSLN"                          "$@"; }
C_3b_CLEAN() { sed -E -e 's/ (\*\*)?\([^)][^)]+\)(\*\*)?//g' -e 's/(\*\*)?\([^)][^)]+\)(\*\*)? //g' | perl -pe 's/(?<!\\)\*//g;' -pe 's/\\\*/\*/g' ;}


# extract packet letters and question numbers
C_1a_Q_NUM ${PREFIX}*${EXT}.tos | C_1b_P_LET > ${PREFIX}tossup.answers.1
C_1a_Q_NUM ${PREFIX}*${EXT}.bon | C_1b_P_LET > ${PREFIX}bonus.answers.1

# extract authors and categories
C_2a_ACTAG ${PREFIX}*${EXT}.tos > ${PREFIX}tossup.answers.2
C_2a_ACTAG ${PREFIX}*${EXT}.bon > ${PREFIX}bonus.answers.2

# extract answerlines (bonus answerlines are concatenated into 3 columns)
echo -e "\nNumber of answerlines found:"
grep --color -E -c "$R_3a_ANSLN" ${PREFIX}*${EXT} 2>&1
C_3a_ANSLN ${PREFIX}*${EXT}.tos | C_3b_CLEAN                       > ${PREFIX}tossup.answers.3
C_3a_ANSLN ${PREFIX}*${EXT}.bon | C_3b_CLEAN | paste -d '\t' - - - > ${PREFIX}bonus.answers.3

paste -d'\t' ${PREFIX}tossup.answers.* > ${PREFIX}tossup.answers
paste -d'\t' ${PREFIX}bonus.answers.*  > ${PREFIX}bonus.answers

echo -e "\nCopy the question metadata from ${PREFIX}tossup.answers and ${PREFIX}bonus.answers.\nPaste the question metadata into the data spreadsheet."
