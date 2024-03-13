source check-nonos-utils.sh

# Should probably still run textutil docx and check this even if using pandoc
check 1 t.o.html "Extracting contents of <style> tags" \
 Check "Each <style> tag should contain only 4 lines, starting with:  ${UL}p.p1${NL}, ${UL}p.p2${NL}, ${UL}p.p3${NL}, ${UL}span.s1${NL}" \
 "awk 'FNR==1{printf \"\033[1;32m\n\" FILENAME \"\033[0m\n\"} /<style/,/<\\/style>/' __"

check 1 t.o.html "Extra CSS rules" "" "" \
 "ack --group --color -v \"\`tr '\n' '|' < transformers/ok-styles.txt\`\" --range-start='<style' --range-end='</style' __"
# NOTE: ack can't do --passthru and --range-* simultaneously

check 1 t.o.html "Extra CSS classes" "" "" \
 "rg --heading --color=always -P -C1 '[\".](s[2-9]|p[4-9]|Apple-(?!converted-space))' __"

check 1 t.o.html "Extra CSS classes" "" "" \
  "for i in __; do echo -e \"\\n$REV\$i$REG\"; awk '/<style/ {a=1} /<\/style/ {a=0} a' \"\$i\" | grep -vf transformers/ok-styles.txt | rg -Po '[^.]+(?= \{)' | tr '\n' '|' | xargs -I '{}' rg --color=always -C2 '[.\"]({}%@)' \"\$i\"; done"
