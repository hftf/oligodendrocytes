export LC_ALL=C

# Remove hardcoding
NONOS="or ten point| each, [^BPn]| each\.|[^0-9]--|\.\.| \.| ,|”’|‘“|“ |‘ | ’| ”|’\.|[^!]’,|”\.|[^!]”,|,[^ ’”*0-9]|’\s?”| |  |'|\"| \[|\.\*\* \(|ANSWER:\S|ANSWER[^:]|ANWER|\\[^*\n$]| "
grep --color -EHn "$NONOS" $@/*.md

echo
echo "(\*)"
grep --color -EiHno '.....\(\\\*\)\S.....' $@/*.md || :

echo
echo "space after newline"
grep --color -EiHnc "^(​|\s)" $@/*.md || :

echo
echo -e "\t  tossups bonuses   parts"
for i in $@/*.qbml; do
echo -e "$i`grep -o '<tossup ' $i | wc -l``grep -o '<bonus ' $i | wc -l``grep -o '<part ' $i | wc -l`"
done

echo
echo "****"
grep --color -EiHn "\*\*\*\*" $@/*.md || :

echo
echo "* *"
grep --color=always -EiHn "..\* \*.." $@/*.md | grep -v ANSWER || :

echo
echo "\\answer{}"
grep --color -EC 4 '\\answer\{\}' $@/*.tex || :

echo
echo "\\\\}"
grep --color -EH '\\\\\}' $@/*.tex || :

#grep -Eo '}[^}]+\\w{[^}0-9A-Za-z]+}{[^}]+}[^}]+}' $@/*.tex
