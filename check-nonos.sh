# Remove hardcoding
NONOS="or ten point| each, [^BPn]| each\.|[^0-9]--|\.\.| \.| \,|“ |‘ | ’| ”|’\.|[^!]’\,|”\.|[^!]”,|,[^ ’”*0-9]|’\s?”| |  |'|\"| \[[^tho]|\.\*\* \(|ANSWER:\S|ANSWER[^:]|ANWER|\\[^*\n$]| "
grep --color -EHn "$NONOS" $@/*.md

echo
echo "(\*)"
grep --color -EiHno '.....\(\\\*\)\S.....' $@/*.md || :

echo
echo "space after newline"
grep --color -EiHnc "^\s" $@/*.md || :

echo
echo "****"
grep --color -EiHn "\*\*\*\*" $@/*.md || :

echo
echo "* *"
grep --color=always -EiHn "..\* \*.." $@/*.md | grep -v ANSWER || :

echo
echo "\\answer{}"
grep --color -EC 4 '\\answer\{\}' $@/*.tex || :
