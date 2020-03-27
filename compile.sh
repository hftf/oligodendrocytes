tournament="mytournament"
base_tournament="oldtournament"

# create tournaments/$tournament folder structure

echo "$tournament" > tournaments/current.txt
mkdir -p tournaments/$tournament/packets

# copy settings

cp -n tournaments/$base_tournament/settings.pxml tournaments/$tournament/
# manually edit settings.pxml

# checks
# TODO script to test if checks pass
# should be all 20
# ack -c 'tu"' terrapin-packets/html/*.f.html
# ack -c 'answer"' terrapin-packets/html/*.f.html



# resetting

make reset
make -j5 formats EXT=f.html

# create web packets bundle folder structure

bundle="2019-tournament"
edition="2019-10-01"
mkdir -p bundles/$bundle/$edition/html/

# manually create folder structure on host

host="myhost.buzz"
hostpath="path/to"
# ssh $host "cd $hostpath && cp -R packets packets-$prev_edition"

# copy the web packets bundle

cp tournaments/$tournament/packets/{*.w.html,*.js,!(fonts).css,*.php,*.png,*.csv} bundles/$bundle/$edition/html/
cp tournaments/$tournament/packets/{*.o.html,*.md,*.md.nowrap}                    bundles/$bundle/$edition/html/
scp bundles/$bundle/$edition/html/{*.w.html,*.js,!(fonts).css,*.php,*.png,*.csv}  $host:$hostpath/tournaments/$tournament/packets/html/

# download pdf/docx packets by exporting directly from google drive

drive pull -export pdf  -exports-dir tournaments/$tournament/packets/docs/pdf/ -explicitly-export -same-exports-dir "Quizbowl/$PACKETS_DIR/Packets"
drive pull -export docx -exports-dir tournaments/$tournament/packets/docs/pdf/ -explicitly-export -same-exports-dir "Quizbowl/$PACKETS_DIR/Packets"

# create the pdf and password protected pdf packets (zips)

cp -n password.sh tournaments/$tournament/packets/docs/pdf/
# manually edit password.sh
# TODO don't hardcode stuff in password.sh
# TODO don't require cd'ing into here
cd tournaments/$tournament/packets/docs/pdf/
./password.sh
zip $tournament-password-pdfs-$edition.zip *.password.pdf
zip $tournament-pdfs-$edition.zip          !(*password).pdf
zip $tournament-docxs-$edition.zip         !(*password).docx
scp $tournament-password-pdfs-$edition.zip $host:$hostpath/tournaments/$tournament/packets/html/password-pdfs.zip
