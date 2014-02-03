set -e

if [[ -z "$1" ]]; then
    echo "Need argument"
    exit 0
fi

echo "fetching"
mkdir -p $1
# need to generalize this
google docs get --folder Final --format docx --dest $1

echo
echo "changing filenames"
pushd $1
for i in *.docx; do
    # and this
    NEW=${i:0:2}.docx
    printf "moving %-42s → $NEW\n" "$i"
    mv "$i" "$NEW"
done
## and this
#echo "removing Fi.docx"
#rm Fi.docx
popd
