PREFIX=$1
BUNDLE=$2
EDITION=$3

shopt -s extglob

# create web packets bundle folder structure

# should really output each command for awareness, like in Make

mkdir -p bundles/$BUNDLE/$EDITION/html/

# copy the web packets bundle
cp transformers/bundle-assets/*.{js,css,php,png} "$PREFIX"

cp "$PREFIX"{*.w.html,*.a.html,*.js,!(fonts).css,*.php,*.png,*.csv} bundles/$BUNDLE/$EDITION/html/
# cp "$PREFIX"{*.o.html,*.md,*.md.nowrap} bundles/$BUNDLE/$EDITION/html/
