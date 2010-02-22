#!/bin/bash
set -e

#
# Show help
#
if [ $# -eq 0 ]
then
    echo "USAGE: pack-it linux/win32"
    exit
fi

#
# Grab the mode
#
mode=$1
if [ $mode != "win32" ] && [ $mode != "linux" ]
then
    echo "Unknown mode: $mode"
    exit
fi

echo "Creating a $mode package for Oblige..."

cd ../..

src=oblige
dest=PACK-RAT

mkdir $dest

#
#  Copy Lua scripts
#
mkdir $dest/scripts
cp -av $src/scripts/*.* $dest/scripts

mkdir $dest/games
cp -av $src/games/*.* $dest/games

mkdir $dest/engines
cp -av $src/engines/*.* $dest/engines

mkdir $dest/mods
cp -av $src/mods/*.* $dest/mods

#
#  Copy data files
#
mkdir $dest/data
mkdir $dest/mods/data

cp -av $src/data/*.lmp $dest/data || true
cp -av $src/data/*.wad $dest/data || true
cp -av $src/data/*.pak $dest/data || true

#
#  Copy executables
#

mkdir $dest/tools

if [ $mode == "linux" ]
then
cp -av $src/Oblige $dest
cp -av $src/qsavetex/qsavetex $dest/tools
else
cp -av $src/Oblige.exe $dest
cp -av $src/qsavetex/qsavetex.exe $dest/tools
fi

#
#  Copy documentation
#
cp -av $src/GPL.txt $dest
cp -av $src/TODO.txt $dest
cp -av $src/README.txt $dest
cp -av $src/WISHLIST.txt $dest
cp -av $src/CHANGES.txt $dest

### cat $src/web/main.css $src/web/index.html > $dest/README.htm

#
# all done
#
echo "------------------------------------"
echo "mv PACK-RAT Oblige-X.XX"
echo "zip -l -r oblige-XXX-win.zip Oblige-X.XX"
echo ""

