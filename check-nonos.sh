NONOS="or ten point| each, [^BPn]| each\.|[^0-9]--|\.\.| \.| \,|“ |‘ | ’| ”|’\.|[^!]’\,|”\.|[^!]”,|,[^ ’”*0-9]|’\s?”| |  |'|\"| \[[^tho]|ANSWER:\S|ANSWER[^:]|ANWER|\\[^*\n$]| "
grep --color -EHn "$NONOS" $@/*.md

echo
echo "(\*)"
for i in $@/*.md; do grep --color -EiHno '.....\(\\\*\)\S.....' "$i" || :; done

echo
echo "space after newline"
for i in $@/*.md; do grep --color -EiHnc "^\s" $i || :; done

echo
echo "****"
for i in $@/*.md; do grep --color -EiHn "\*\*\*\*" $i || :; done

echo
echo "\\answer{}"
for i in $@/*.tex; do grep --color -EC 4 '\\answer\{\}' $i || :; done
