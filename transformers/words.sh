PREFIX=$1
EXT=.w.html

rg -IP -or='$1' '<m v="(\d+)">([^<\n]|<[^m])+</b>(?!.*</b>)'  ${PREFIX}*${EXT} > ${PREFIX}tossup.words.power
rg -IP -or='$1' '<m v="(\d+)">([^<\n]|<[^m])+</p>$'           ${PREFIX}*${EXT} > ${PREFIX}tossup.words.all

paste -d'\t' ${PREFIX}tossup.words.power ${PREFIX}tossup.words.all > ${PREFIX}tossup.words
wc -l        ${PREFIX}tossup.words.power ${PREFIX}tossup.words.all

echo -e "\nCopy the words metadata from ${PREFIX}tossup.words.\nPaste the words metadata into the data spreadsheet."
