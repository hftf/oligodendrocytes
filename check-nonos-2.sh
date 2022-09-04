source check-nonos-utils.sh

# check 9 f.html "test for quoting"  "" "" "ack --color ' id=\"bonuses\"|'\' __"
# check 9 f.html "test for escaping" "" "" "echo '\n\\n\\\n\\\\n \\x7F'"
dont() {

# don't
pcregrep --color=always -M '<p><br /></p>\n<p>[^TB].*?</p>\n<p>[^A[]' $PREFIX!(*.o).html
#pcregrep --color=always -M '(?<!<p>)<br />' $PREFIX!(*.o).html
#pcregrep --color=always -M '<br />(?!</p>)' $PREFIX!(*.o).html
pcregrep --color=always -M '<p> ' $PREFIX!(*.o).html

check 1 o.html "Soft line breaks (or <br> in HTML)" \
 Remedy "Replace with paragraphs in source document" \
 "rg --heading --color=always -C1 '<br(?: /)?>$' __"

check 1 f.html "Count of ${UL}tu\"${NL}, ${UL}bonus\"${NL}, and ${UL}ANSWER:${NL}" \
 Check "All counts should equal 120 (20 tu + 20 bonus + 80 answer)" \
 "grep --color=always -E -c 'tu\"|bonus\"|ANSWER: ' __"

# TODO: count up <author> tags here
# count up total tags i.e. <
check 2 answers "Count of unique categories" "" "" \
 "cat __ | cut -f4 | sort | uniq -c | sort -nrk1"
check 2 answers "Count of unique authors" "" "" \
 "cat __ | cut -f3 | sort | uniq -c | sort -nrk1"

check 2 answers "Long answers" "" "" \
 "awk 'BEGIN { FS=OFS=\"\t\" } { for (i=5; i<=NF; i++) if (length(\$i) >= 30) print \$1,gensub(/^.+\\/(.+)\\..+$/,\"\\\\1\",\"g\",FILENAME),\$2,length(\$i),\$i}' __"
check 2 answers "Special characters in parsed tags or answers" \
 Check "If should be removed" \
 "rg --heading --color=always '[\\\\()\\[\\]#_*^~]' __"


check 2 md.nowrap "Bonus marker count" \
  Check "Should have the same number of each marker" \
 "rg -I -o '^\\\\?\[(?:10)?[emhEMH\S]*' __ | sort | uniq -c"

check 2 md.nowrap "Line count" \
 Check "All files should have the same number of lines (false positives: shorter tiebreaker packets)" \
 "wc -l __"

check 2 md "Serial comma" "" "" "grep --color=always -Hn ',\s+\S+[^,]\s+(and|or)\s' __"

check 3 md "Unnecessary moderator notes (${UL}moderator${NL})" \
 Check "If the question can be improved another way" \
 "grep --color=always -iHn 'moderator' __"
# TODO: add note to player

check 3 md "${UL}which${NL} vs. ${UL}that${NL}" \
 Check "If ${UL}which${NL} should be replaced by ${UL}that${NL} (false positives: quotations)" \
 "rg --heading --color=always -P -i '(?<!(?:....(?:.,|,[\"”])|... (?:in|of|to|at|on|by)|.. (?:for|and|but)|. (?:from|with|upon|into|onto|over)| after| under| among| about| above| below|around|during|hrough|ithout|toward)) which' __"
# TODO: add past|across
# TODO: not followed by (states|says|etc.) that
# TODO: which should be always lowercase
# TODO: use nowrap

# tregex.sh '@SBAR <<: S' -- $PREFIX*.parsed
# Tregex: SBAR !$,, /,/ & < (WHNP <<: which)

# TODO: add phrasal -ing -ed (-designed)
# TODO: add non-
# TODO: add languagetool
# TODO: add [] - see docx-to-unparsed.sh

}
dont

# informative checks only
# nbsp:
# ack -ho --mn '(?:\S* )+\S+' $PREFIX | sort
# ruby:
# ack -oh '\S+\s*(?<!class="text">)<ruby>.*?</ruby>\s*\S+' $PREFIX*.r.html | sed -E 's@(<ruby><rb>|</rb><rp>|</rp><rt>|</rt><rp>|</rp></ruby>)@'$'\t@g' | column -ts$'\t'
# TODO: unparsed (malformatted) PGs
# ack '\[“\w' tournaments/hft19/packets/*.r.html
# num of ruby should match num of (" ")

# TODO: check caverphone - PGs that may be wrong (number of words too short/long)
# see instrucs in htmlparser


# check 1
rg '[^>]&lt;' $PREFIX*.o.html

check 3 o.html "Bold tag interrupted" \
 Check "If should be removed" \
 "rg --heading --color=always '<p( class=\"p1[^\"]*\")?>\d.*</(b|strong)>.*<(b|strong)>[^<]' __"

# TODO: count tags (valid) - need commas
check 4 md "Count tags" "" "" \
 "rg --color=always -c '\\\\<(.*)\\\\>' __"

# exit

function dont1() {
# TODO: start after the packet header
# TODO: should be nowrap
check 3 md "Hyphen between two capitalized words" \
 Check "If an en dash should be used for doubly eponymous" \
 "rg --heading --color=always -P '(?!Naveh-Benjamin|Co-Head)\p{Lu}\p{Ll}+-\p{Lu}\p{Ll}+' __"

# TODO: should be nowrap
# TODO: pipe out to http://jwilk.net/software/anorack
#   anorack | while IFS=: read -r f l e; do echo -e "\n$f:$l\n$e"; sed -n "${l}p" $f; done
check 3 md "Wrong usage of a/an" \
 Check "If ${UL}a${NL} + vowel or ${UL}an${NL} + consonant usage is correct (false positives: initialisms, silent H, consonantal U, medial A)" \
 "rg --heading --color=always -P '\b[Aa] (?![\\\\[(]*emphasize)[()\[\]\\\\* ]*+(?!(?i)(uni(?:vers|form)|union|uniqu|utopi|Euro|USA?|[U][A-Z]*\b))[AEIOUaeiou]| an [()\[\]\\\\* ]*+(?!1[18]|8|[HS][A-Z]*\b)[^aeiouAEIOUéÉ<“]' __"
# TODO: fix for Packet by Columbia A and Texas A

check 4 md.nowrap "Short sentences starting with “That”" \
 Check "If a semicolon should connect the previous sentence instead (false positives: initials)" \
 "rg --heading --color=always -o '\. That.{0,70}\.\S*' __"
}
dont1

check 4 txt "First full pronoun is too far into tossup (70 chars, ignoring PGs)" \
 Check "If the pronoun can be moved earlier instead" \
 "rg --heading --color=always -P -n -ior '\$a►\$b' '^(?P<a>\d+\. (?>(?> [([](?!this|these).*?[)\]])*+(?!(?&r)).){70}.*?)(?P<b>(?P<r>this|these) \S+(?!.*points each))' __ | awk '/[0-9]. /{o=\$0;\$1=\"\";match(\$0,\"^[^►]*\");printf(\"%4s %s\n\",RLENGTH-1,o);next}{print}'"
# reimplement ack's --range-end='Bonuses' for rg
# "ack -i --range-end='Bonuses' '^\d+\. .*?\K(?:this|these)(*PRUNE)(?<=.{70}) \S+' __"
# "sed '/^Bonuses/Iq' __ | rg --color=always -P -n -io '^\d+\. (?>(?> [([](?!this|these).*?[)\]])*+(?!(?1)).){70}.*?(this|these) \S+'"
# TODO: he him his [this
# TODO: ignore *Note to ... .*

check 5 md.nowrap "List of all non-ASCII characters" "" "" \
 "grep -Poh '[^\\x00-\\x7F]' __ | sort | uniq | tr -d '\n'; echo"

check 5 md "List instances of most non-ASCII characters" "" "" \
 "rg --color=always '[^\\x00-\\x7F\\xC0-\\xD6\\xD8-\\xF6\\xF8-\\xFF ​–—‘’“”…]' __"


# check 5 log "Obsolete LaTeX checks" "" "" \
#  "grep --color -EHnA4 'Missing|erfull' __"

# TODO: add test document (tests/checks/)
# TODO: can space ( ) be changed to [ \n] to work with md? or md.nowrap
# TODO: if glob resolves to no files then skip? or show error message?
# TODO: filter by priority

### TODO: ack -c <m w.html
# TODO: check numbering goes in order
# TODO: show frequency=1 authors and categories in context
# TODO: check if frequency<4 tags are typo
# TODO: grep " >"
# TODO: grep "[(this|etc)"
# TODO: grep "(?)" power marks
# TODO: questions or bonus parts that don't end in punctuation mark

# words.sh: add report with histogram; number of PGs (per packet)

# rg --color=always 'Answer ' $PREFIX*.md.nowrap
