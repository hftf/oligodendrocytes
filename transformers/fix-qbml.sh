# note: \& refers to the entire match
sed -E 's/[%$#_]|&amp;/\\&/g'
