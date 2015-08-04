#!/bin/bash

BR_TOP="$(pwd)"

for i in $(ls $BR_TOP/configs | grep RASP); do
echo "Compiling with config "$i
make $i
make -j8
mkdir -p output/images/$i
cp output/images/zImage output/images/$i/
cp -L output/images/rootfs.ext3 output/images/$i/
done

bash $BR_TOP/scripts/build_sdcard.sh $BR_TOP/output/images/
