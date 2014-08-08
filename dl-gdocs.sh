set -e

if [ $# -ne 4 ]; then
    echo "Need 4 arguments"
    exit 0
fi

echo "fetching"
mkdir -p $1
google docs get --folder "$2" --format docx --dest $1

echo
echo "changing filenames"
pushd $1
for i in *.docx; do
    NEW=${i:$3:$4}.docx
    printf "moving %-42s → $NEW\n" "$i"
    mv "$i" "$NEW"
done
## and this
#echo "removing Fi.docx"
#rm Fi.docx
popd
