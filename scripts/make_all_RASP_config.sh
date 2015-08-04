#!/bin/bash

BR_TOP="$(pwd)"

for i in $(ls $BR_TOP/configs | grep RASP_ | sed 's/\_defconfig//g'); do
echo "Compiling with config "$i"_defconfig"
make "$i"_defconfig
make -j8
mkdir -p output/images/$i
cp output/images/zImage output/images/$i/
cp -L output/images/rootfs.ext3 output/images/$i/

#Force Kernel and rootfs rebuild
rm -rf output/build/linux-7*
rm -rf output/images/rootfs*
done

bash $BR_TOP/scripts/build_sdcard.sh $BR_TOP/output/images/
