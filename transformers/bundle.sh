PREFIX=$1
BUNDLE=$2
EDITION=$3

shopt -s extglob

# create web packets bundle folder structure

mkdir -p bundles/$BUNDLE/$EDITION/html/

# copy the web packets bundle
cp transformers/bundle-assets/*.{js,css,php,png} "$PREFIX"

cp "$PREFIX"{*.w.html,*.js,!(fonts).css,*.php,*.png,*.csv} bundles/$BUNDLE/$EDITION/html/
# cp "$PREFIX"{*.o.html,*.md,*.md.nowrap} bundles/$BUNDLE/$EDITION/html/
