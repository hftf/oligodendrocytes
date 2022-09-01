shopt -s extglob
PREFIX="$@"
GREP_COLOR='1;4;31;103'
# seemingly adds Unicode support for ack
export PERL_UNICODE=SAD

BOLD=`tput bold`
REV=`tput setaf 4``tput rev`
CLR=`tput setaf 4`
REG=`tput sgr0`
RED=`tput setaf 9``tput rev`
GREY=`tput setab 15`
NAVY=`tput setaf 18`
BLUE=`tput setaf 12`
GREEN=`tput setab 10`
UL=`tput smul`
NL=`tput rmul`

function check {
	priority=$1
	extension=$2
	checkname=$3
	checktype=$4
	checkdesc=$5
	command=$6
	set -f
	wildcard=*.

	PCLR=$GREEN; if [ $priority -eq 1 ]; then PCLR=$RED; fi
	printf "$BLUE%-10s$REG $BOLD$PCLR P$priority $REG$BOLD$REV $checkname $REG\n" $extension
	if [ -n "$checkdesc" ]; then
		printf "%-10s $CLR $checkdesc $REG\n" "$checktype:"
	fi

	# TODO: if command has no output, don't print
	if [ -n "$command" ]; then
		commandescaped=${command//\\/\\\\}
		commandpretty=${commandescaped/__/$NAVY$PREFIX$wildcard$BLUE$extension$REG$GREY}
		fullcommand=${command/__/$PREFIX$wildcard$extension}
		printf "%-10s $GREY $commandpretty $REG\n\n" "Command:"
		set +f
		# set -x
		eval "${fullcommand//\\/\\}"
		# { set +x; } 2>/dev/null
	fi
	echo
}

# check 9 f.html "test for quoting"  "" "" "ack --color ' id=\"bonuses\"|'\' __"
# check 9 f.html "test for escaping" "" "" "echo '\n\\n\\\n\\\\n \\x7F'"
dont() {

# don't
pcregrep --color -M '<p><br /></p>\n<p>[^TB].*?</p>\n<p>[^A[]' $PREFIX!(*.o).html
pcregrep --color -M '(?<!<p>)<br />' $PREFIX!(*.o).html
pcregrep --color -M '<br />(?!</p>)' $PREFIX!(*.o).html
pcregrep --color -M '<p> ' $PREFIX!(*.o).html

check 1 o.html "Soft line breaks (or <br> in HTML)" \
 Remedy "Replace with paragraphs in source document" \
 "rg --heading --color=always -C1 '<br>$' __"

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
 "rg -I -o '^\[(?:10)?[emh\S]*' __ | sort | uniq -c"

check 2 md.nowrap "Line count" \
 Check "All files should have the same number of lines (false positives: shorter tiebreaker packets)" \
 "wc -l __"

check 2 md "Serial comma" "" "" "grep --color=always -Hn ',\s+\S+[^,]\s+and\s' __"

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

# Should probably still run textutil docx and check this even if using pandoc
check 1 o.html "Extracting contents of <style> tags" \
 Check "Each <style> tag should contain only 4 lines, starting with:  ${UL}p.p1${NL}, ${UL}p.p2${NL}, ${UL}p.p3${NL}, ${UL}span.s1${NL}" \
 "awk 'FNR==1{printf \"\033[1;32m\n\" FILENAME \"\033[0m\n\"} /<style/,/<\\/style>/' __"

check 1 o.html "Extra CSS rules" "" "" \
 "rg --heading --color=always -v \"\`tr '\n' '|' < transformers/ok-styles.txt\`\" --range-start='<style' --range-end='</style' __"
# NOTE: ack can't do --passthru and --range-* simultaneously

check 1 f.html "Extra CSS classes" "" "" \
 "rg --heading --color=always -P -C1 '[\".](s[2-9]|p[4-9]|Apple-(?!converted-space))' __"

# for i in $PREFIX*.o.html; do awk '/<style/ {a=1} /<\/style/ {a=0} a' $i | grep -vf tournaments/nasat18/ok-styles.txt | ack -o '[^.]+(?= {)' | tr '\n' '|' | xargs -I '{}' ack -C2 "'[.\"]({}%@)'" "$i"; done

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
 "rg --heading --color=always '<p class=\"p1[^\"]*\">\d.*</b>.*<b>[^<]' __"

# TODO: count tags (valid) - need commas
rg --color=always -c -I '\\<(.*)\\>' $PREFIX*.md

# exit

function dont1() {
# TODO: start after the packet header
# TODO: should be nowrap
check 3 md "Hyphen between two capitalized words" \
 Check "If an en dash should be used for doubly eponymous" \
 "rg --heading --color=always '\p{Lu}\p{Ll}+-\p{Lu}\p{Ll}+' __"

# TODO: should be nowrap
# TODO: pipe out to http://jwilk.net/software/anorack
#   anorack | while IFS=: read -r f l e; do echo -e "\n$f:$l\n$e"; sed -n "${l}p" $f; done
check 3 md "Wrong usage of a/an" \
 Check "If ${UL}a${NL} + vowel or ${UL}an${NL} + consonant usage is correct (false positives: initialisms, silent H, consonantal U, medial A)" \
 "rg --heading --color=always -P '\b[Aa] [()\[\]\\\\* ]*+[AEIOUaeiou]| an [()\[\]\\\\* ]*+(?!1[18])[^aeiouAEIOU<“]' __"
# TODO: fix for Packet by Columbia A and Texas A

check 4 md.nowrap "Short sentences starting with “That”" \
 Check "If a semicolon should connect the previous sentence instead (false positives: initials)" \
 "rg --heading --color=always -o '\. That.{0,70}\.\S*' __"
}
dont1

check 4 txt "First full pronoun is too far into tossup (70 chars, ignoring PGs)" \
 Check "If the pronoun can be moved earlier instead" \
 "rg --heading --color=always -P -n -io '^\d+\. (?>(?> [([](?!this|these).*?[)\]])*+(?!(?1)).){70}.*?(this|these) \S+' __"
# reimplement ack's --range-end='Bonuses' for rg
# "ack -i --range-end='Bonuses' '^\d+\. .*?\K(?:this|these)(*PRUNE)(?<=.{70}) \S+' __"
# TODO: he him his [this

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
