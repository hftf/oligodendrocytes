PREFIX=$1

# create web packets bundle folder structure

bundle="2019-tournament"
edition="2019-10-01"
mkdir -p bundles/$bundle/$edition/html/

# copy the web packets bundle
cp transformers/bundle-assets/*.{js,css,php,png} "$PREFIX"

cp "$PREFIX"{*.w.html,*.js,!(fonts).css,*.php,*.png,*.csv} bundles/$bundle/$edition/html/
#cp "$PREFIX"{*.o.html,*.md,*.md.nowrap}                    bundles/$bundle/$edition/html/
