tournament="terrapin3"
base_tournament="terrapin2"

# create tournaments/$tournament folder structure

echo "$tournament" > tournaments/current.txt
mkdir tournaments/$tournament
mkdir tournaments/$tournament/packets

# copy settings and packet order

cp tournaments/$base_tournament/settings.pxml tournaments/$tournament/
cp tournaments/$base_tournament/order.txt tournaments/$tournament/

# create $tournament-packets/ folder structure

mkdir $tournament-packets/
cd $tournament-packets/
mkdir docx docx-password html pdf pdf-password
cd -
touch $tournament-packets/html/\!please-remember-to-fully-extract-the-zip-archive

# copy assets for html

cp $base_tournament-packets/html/!(*.f.html) $tournament-packets/html

# checks
# TODO script to test if checks pass
# should be all 20
# ack -c 'tu"' terrapin-packets/html/*.f.html
# ack -c 'answer"' terrapin-packets/html/*.f.html



# resetting

make reset
make -j5 formats EXT=f.html

# copy the docx and f.html packets

cp tournaments/$tournament/packets/*.f.html $tournament-packets/html/
cp tournaments/$tournament/packets/*.docx $tournament-packets/docx/

# create the pdf and password protected packets

# TODO don't require cd'ing into here
# TODO don't hardcode stuff in password.sh
cd $tournament-packets/docx/
./password.sh
cd -

# cp password.sh $tournament-packets/docx/password.sh
# cp number.js $tournament-packets/html/number.js

# create zip
rm $tournament-packets.zip
zip $tournament-packets.zip -r $tournament-packets/
