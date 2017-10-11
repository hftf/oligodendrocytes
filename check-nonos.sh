export LC_ALL=C
PREFIX="$@"

# TODO Remove hardcoding, remove [^stuff]
# TODO separate file with list of regexes with description, example, priority, category
# combined with http://search.cpan.org/~rsavage/Regexp-Assemble-0.38/lib/Regexp/Assemble.pm
# TODO sort by packet, nono
# TODO one-click fixes

NONOS1="or ten point| each, [^BPn]|etc[^a-z.]|[^a-z]i\.? ?e\.|[^a-z]e\.? ?g\."
NONOS2="ANSWER:\S|ANSWER[^:]|Answer:|ANWER|(?<!or )prompt on (\*|“|\")|not reveal|, (prompt(?!ing)|accept|do not prompt)|anti(-| |)prompt|NOT |foremention|accept either"
NONOS3="\.[A-Z]|\s[A-Z]{,3}\.\s[A-Z]|[0-9]-[0-9]|\. [a-z]|([^,] f|[^.!*\"”] F)or 10 points| points:|for 10 points each:|10 point[^s]"
NONOS4="teenth|tieth|logical equiv|obvious equiv|lenient|[^0-9][.!?] [0-9]|[~^]|­|•|\\$|\\#|[\[\(]\s|\s[\]\)]|s’\s"
NONOS5="[^0-9]--|\.\.| \.|…[!?.]?\S| ,|”’|‘“|[^( *]“|“ |‘ | ’| ”|’\.|[^!]’,|”\.|[^!]”,|,[^ ’”*0-9]|’\s?”| |\s\s|'|\"|\.\*\* \(|\\[^*\n$]|[^!.] | $|  |  "
NONOS="$NONOS1|$NONOS2|$NONOS3|$NONOS4|$NONOS5"

OKAYS="\S[[(]|[])]\S|\([^\][^*]|[^*]\*th[ie]s| each\."
OKAYS2="\[[A-Z]|-\s|\s-|[^0-9  ]/|/[^0-9  ]"

grep --color=always -EHn "$NONOS" $PREFIX*.md

#echo
#echo "(\*)"
#grep --color=always -EiHno '.{,5}\(\\\*\)\S.{,5}' $PREFIX*.md || :

echo
echo "space after newline"
grep --color=always -EiHnc "^(​|\s)" $PREFIX*.md || :

echo
echo "****"
grep --color=always -EiHn "\*\*\*\*" $PREFIX*.md || :

#echo
#echo "* *"
#not useful for PGs written with <span><b>
####grep --color=always -EiHn "..\* \*.." $PREFIX*.md | grep -v ANSWER || :


echo
echo '"answers required." "Description acceptable." and titles with ending punctuation'
echo "[,.?!]*"
grep --color=always -PiHn "(?<!\.\w)[.,?!]\*(?!\*)" $PREFIX*.md || :


# echo
# echo -e "\t  tossups bonuses   parts"
# for i in $PREFIX*.qbml; do
# echo -e "$i`grep -o '<tossup ' $i | wc -l``grep -o '<bonus ' $i | wc -l``grep -o '<part ' $i | wc -l`"
# done
