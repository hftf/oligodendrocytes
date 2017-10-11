export LC_ALL=C
PREFIX="$@"

# Remove hardcoding
NONOS="or ten point| each, [^BPn]| each\.|[^0-9]--|\.\.| \.|…\.?\S| ,|”’|‘“|“ |‘ | ’| ”|’\.|[^!]’,|”\.|[^!]”,|,[^ ’”*0-9]|’\s?”| |  |'|\"| \[|\.\*\* \(|ANSWER:\S|ANSWER[^:]|ANWER|\\[^*\n$]| "
grep --color=always -EHn "$NONOS" $PREFIX*.md

echo
echo "(\*)"
grep --color=always -EiHno '.{,5}\(\\\*\)\S.{,5}' $PREFIX*.md || :

echo
echo "space after newline"
grep --color=always -EiHnc "^(​|\s)" $PREFIX*.md || :

echo
echo -e "\t  tossups bonuses   parts"
for i in $PREFIX*.qbml; do
echo -e "$i`grep -o '<tossup ' $i | wc -l``grep -o '<bonus ' $i | wc -l``grep -o '<part ' $i | wc -l`"
done

echo
echo "****"
grep --color=always -EiHn "\*\*\*\*" $PREFIX*.md || :

echo
echo "* *"
grep --color=always -EiHn "..\* \*.." $PREFIX*.md | grep -v ANSWER || :


echo
echo "[,.?!]*"
grep --color=always -PiHn "(?<!\.\w)[.,?!]\*(?!\*)" $PREFIX*.md || :

echo
echo "\\answer{}"
grep --color=always -EC 4 '\\answer\{\}' $PREFIX*.tex || :

echo
echo "\\\\}"
grep --color=always -EH '\\\\\}' $PREFIX*.tex || :

#grep -Eo '}[^}]+\\w{[^}0-9A-Za-z]+}{[^}]+}[^}]+}' $PREFIX*.tex
