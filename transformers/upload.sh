PREFIX=$1

DATE=`date "+%F"`

EDITION=$DATE

ZIPS="$PREFIX"zips/docxs-$DATE.zip \
	 "$PREFIX"zips/pdfs-$DATE.zip  \
	 "$PREFIX"zips/password-pdfs-$DATE.zip

# manually create folder structure on host

host="myhost.buzz"
hostpath="path/to"
# ssh $host "cd $hostpath && cp -R packets packets-$prev_edition"

scp bundles/$bundle/$edition/html/{*.w.html,*.js,!(fonts).css,*.php,*.png,*.csv} \
 	$host:$hostpath/"$PREFIX"html/
scp $ZIPS \
	$host:$hostpath/"$PREFIX"html/
# specifically to $host:$hostpath/$PREFIX/html/password-pdfs.zip
