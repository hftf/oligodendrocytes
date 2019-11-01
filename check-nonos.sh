PREFIX="$@"
GREP_COLOR='1;4;31;103'

# TODO Remove hardcoding, remove [^stuff]
# TODO separate file with list of regexes with description, example, priority, category
# combined with http://search.cpan.org/~rsavage/Regexp-Assemble-0.38/lib/Regexp/Assemble.pm
# TODO sort by packet, nono
# TODO one-click fixes

NONOS1="or ten point| each, [^BPn]|etc[^a-z.]|[^a-z]i\.? ?e\.|[^a-z]e\.? ?g\."
NONOS2="ANSWER:\S|ANSWER[^:]|Answer:|ANWER|ASNWER|(?<!or )prompt on (\*|“|\")|not reveal|, (prompt(?!ing)|accept|do not prompt)|anti(-| |)prompt|NOT |before mention|until mention|foremention|accept either|accept also|by asking|by saying|with “|some questions|[\[ ]Edited|prompt or|, (prompt|accept| do not accept)| (alone|by itself|by themselves)\]"
NONOS3="\.[A-Z]| [A-Z]{,3}\. [A-Z]|[0-9]-[0-9]|\. [a-z]|([^,”] f|[^.!*\"”] F)or 10 points| points:|10 points [^e]|for 10 points each:|10 point[^s]|points each,\s*$"
NONOS4="teenth|tieth|logical equiv|obvious equiv|lenient|[^0-9][.!?] [0-9]|[~^]|­|•|\\$|\\#|[\[\(]\s|\s[\]\)]|s’\s"
NONOS5="[^0-9]--|\.\.| \.|…[!?.]?\S| ,|”’|‘“|[^([ *]“|“ |‘ | ’[^0-9]| ”|’\.|[^!]’,|”\.|”\w|[^!]”,|,[^ ’”*0-9]|’\s?”|;[’”]| |\s\s|·|ʿ|ʾ|'|\"|\.\*\* \(|[\.,] \*\*\(|\\[^*\n$]|\\[[APOD]|	| $| \(|  |  |\s\*+$|\*\* \*\*"
NONOS6="\(\\\\\*\)($|[^*])|\*\\\\<|\\\\>\*|\\\\<\w+\.| \\\\<"
NONOS="$NONOS1|$NONOS2|$NONOS3|$NONOS4|$NONOS5|$NONOS6"

OKAYS="\S[[(]|[])]\S|\([^\][^*]| each\.|[^.!?”] "
OKAYS2="\[[A-Z]|-\s|\s-|[^0-9  ]/|/[^0-9  ]|(^|[^*])\*th[ie]s"

grep --color=always -EHn "$NONOS" $PREFIX*.md

# ﬀﬁﬂﬃﬄ
# NONOS2: accept or| mention|or prompt|reveal|
# NONOS2: search for ", or" without false positives
# more Dr. Mr. X etc. need nbsp
# Titles like Foo? Bar! need nbsp
# add quizbowlese: towards, possess, conflict, titular
#|[A-Z]\w+-[A-Z][a-z]|\([Tac-z]|[^.]”?\)$|[aA][wW][-”]|[!?.]” [a-z]|reasonable|clear[ -]knowledge|synonym|underlined|possess|minus|s’\s|
# NONOS4:teenth, tieth -> ~~[ -]century
# power that doesn't end at (*)
# ANSWER: ([Tt]he|[Aa])\b
# ”\w

# extremely naive: '\s[\(\[](?! ... )[^\)\]]+[\)\]]'
# keep: [this author] [his namesake unit] [here] [these things] [this]
# [do this action] [one of these places] [3,3]-sigmatropic [this type of person] [Abridged]
# delete: [read slowly] [emphasize] [pause]

# “\*
# double spaces pack 13
# ** (*) pack 12
# addie stray **.** pack 12
# For 10 points no comma pac 11
# or...policy**. instead of ,
# . and , instead of ; in answerlines
# space …
# ** ** packet 4 electric
# packet 14 **. **
# packet 9 “
# packet 14 St. E
# fix prompt regex above returns prompting

# normalize:
# "do not accept" vs. "do not accept or prompt on"
# ANSWER.*\* and \*  -> AND, OR

# JR-esque pronoun emphasis
# \*(this|these)

# doubly-eponymous en-dash
# [A-Z][a-z]+-[A-Z][a-z]+
# need to use unicode uppercase/lowercase

# double words
# the the, the a, and and, of of, a the, the in
# duplicate words
# '\b(\w+)\s\1\b'

# which instead of that
# ack -i '(?<!(?:.....,|....,"|..,”|... (?:in|of|to|at|on)|.. (?:for|and|but)|. from|. with|. upon| among| under| after|during|hrough)) which'
# Tregex: SBAR !$,, /,/ & < (WHNP <<: which)

# that,: It indicates that, in the 17th century, ...

# no punct at end of line

# PGs?
# grep -oP '(\S+ (?:\[(?:“|")|(?-1))[^\]\s]+(?: |"|”))\]'

#### /
#### nbsp
#### mixed content words (in xml sense)
# (“Foo”|)|,

# a/an correct usage
# \b[Aa] [AEIOUaeiou]
# \b[Aa]n [^AEIOUaeiou]
# ' an [()\[\]\\* ]*+(?!1[18])[^aeiouAEIOU<“]'
# change \b to probably space
# fix the second one to look past some punctuation “ \( \(\\\*\)\*\*
# also numbers 8, 18, 18xx starts with vowel (and vice versa); single letters A E F I L M N but not U; mRNA

# accept A, B, C with no or.

# et. al (etc.)
# WWI
# points each,

# regexes for fixing straight quotes to smart quotes automatically http://smartquotesjs.com/
# regexes for moving punctuation inside annotation https://github.com/jgm/pandoc-citeproc/issues/256


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
