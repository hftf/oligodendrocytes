FILENAME="$1"

# TODO delete Bonuses line? delete tiebreaker instructions?
# TODO remove PGs and (*) in less naive way
textutil -convert txt $FILENAME -stdout \
	| sed '1,/Tossups/d' \
	| perl -CSD -pe 's/\x{2028}|\x0c/\n/g' \
	| sed -E 's/^ANSWER: .*|^[0-9]+\. |For 10 points each:|\[10] //g' \
	| perl -pe 's/\s[\(\[](?!(?:this|these|his|here|one|do|\d) )[^\)\]]+[\)\]]//g'
