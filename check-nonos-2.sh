PREFIX=$@

grep --color -Hn ',\s+\S+[^,]\s+and\s' $PREFIX*.md
grep --color -iHn 'moderat' $PREFIX*.md

shopt -s extglob
pcregrep --color -M '<p><br /></p>\n<p>[^TB].*?</p>\n<p>[^A[]' $PREFIX!(*.o).html
pcregrep --color -M '(?<!<p>)<br />' $PREFIX!(*.o).html
pcregrep --color -M '<br />(?!</p>)' $PREFIX!(*.o).html
pcregrep --color -M '<p> ' $PREFIX!(*.o).html

grep -Eo '\. That.{,70}\.' $PREFIX*.o.html

grep --color -Hn 'Missing' $PREFIX*.log
grep --color -HnA4 'erfull' $PREFIX*.log
