FILE="$1"

# all regexes
PRON_START_TAG='<span class=\"s\d\">'
PRON_END_TAG='<\/span>'
PRON_START_BRACKET='\['
PRON_END_BRACKET='\]'
PRON_SYLLABLE_BREAK='-'
PRON_WORD_BREAK=' '

START_QUOTE='(?:\"|“)?'
# START_QUOTE=''
END_QUOTE='(?:\"|”)?'
END_QUOTE_OR_SPACE="(?: |$END_QUOTE?)"
WORD='[^\]]+'
EXTRA_TAGS='(?:<[^>]>)*'
WHITESPACE='\h'


MD_REGEX="($WORD (?:$PRON_START_BRACKET$START_QUOTE|(?-1))$WORD$END_QUOTE_OR_SPACE)(?<=$PRON_END_BRACKET)"
HTML_REGEX="($WORD (?:$PRON_START_TAG$PRON_START_BRACKET$START_QUOTE|(?1))$WORD$END_QUOTE_OR_SPACE)$PRON_END_TAG"

HTML_REGEX1="(?<ws>$WHITESPACE)(?:$PRON_START_TAG)(?<sb>$PRON_START_BRACKET$START_QUOTE)(?<wd>$WORD)(?<eb>$END_QUOTE$PRON_END_BRACKET)(?:$PRON_END_TAG)"
echo $HTML_REGEX1

# ack -o "$HTML_REGEX" "$FILE"

# perl -p -e "s/$HTML_REGEX2/b/g" "$FILE"
perl -p -e "s@$HTML_REGEX1@<rp>$+{ws}$+{sb}</rp><rt>$+{wd}</rt><rp>$+{eb}</rp>@g" <<< 'been relieved if Liu Bei <span class="s1">[loo bay]</span>, a character'

# ack "$PRON_START_TAG" "$FILE"
