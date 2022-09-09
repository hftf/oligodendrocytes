PREFIX=$1
BUNDLE=$2
EDITION=$3

shopt -s extglob

#ZIPS="$PREFIX"zips/docxs-$EDITION.zip \
#	 "$PREFIX"zips/pdfs-$EDITION.zip  \
#	 "$PREFIX"zips/password-pdfs-$EDITION.zip

# manually create folder structure on host

HOST="gwinnett"
HOSTPATH="~/minkowski.space/quizbowl/"
# ssh $HOST "cd $HOSTPATH/PREFIX && cp -R packets packets-$prev_edition"

scp bundles/$BUNDLE/$EDITION/html/{*.w.html,*.js,!(fonts).css,*.php,*.png,*.csv} \
 	$HOST:"$HOSTPATH$PREFIX"html/
#scp $ZIPS \
# 	$HOST:"$HOSTPATH$PREFIX"html/
# specifically to $host:$hostpath/$PREFIX/html/password-pdfs.zip
