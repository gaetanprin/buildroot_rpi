#!/bin/bash
#
# Create an image that can by written onto a SD card using dd.
#
# The disk layout used is:
#
#    0                      -> IMAGE_ROOTFS_ALIGNMENT         - reserved for other data
#    IMAGE_ROOTFS_ALIGNMENT -> BOOT_SPACE                     - bootloader and kernel
#    BOOT_SPACE             -> IMAGE_ROOTFS_ALIGNMENT + BOOT_SPACE + IMAGE_ROOTFS_SIZE                    - rootfs
#
#
#                                                     Default Free space = 1.3x
#                                                     Use IMAGE_OVERHEAD_FACTOR to add more space
#                                                     <--------->
#            4MiB              20MiB    SDIMG_ROOTFS1        2         3
# <-----------------------> <----------> <-----------><----------><---------->
#  ------------------------ ------------ ------------  ----------  ----------
# | IMAGE_ROOTFS_ALIGNMENT | BOOT_SPACE |           ROOTFS_SIZE * 3           |
#  ------------------------ ------------ -------------------------------------
# ^                        ^            ^                        ^
# |                        |            |                        |
# 0                      4MiB     4MiB + 20MiB       4MiB + 20Mib + SDIMG_ROOTFS

CURRENT_DIR=$1

# SD Card image
SDIMG=${CURRENT_DIR}/rpi-sdcard.img

echo
echo "*** Building SD-card `basename ${SDIMG}` ***"
echo
# Boot partition size [in KiB] (will be rounded up to IMAGE_ROOTFS_ALIGNMENT)

BOOT_SPACE="40960"

# Set alignment to 4MB [in KiB]
IMAGE_ROOTFS_ALIGNMENT="4096"

# Use an uncompressed ext2/3/4 by default as rootfs
SDIMG_ROOTFS_TYPE="ext3"
SDIMG_ROOTFS="${CURRENT_DIR}/rootfs.${SDIMG_ROOTFS_TYPE}"

# Additional files and/or directories to be copied into the vfat partition from the IMAGE_ROOTFS.
FATPAYLOAD=""

# Align partitions
BOOT_SPACE_ALIGNED=$(expr ${BOOT_SPACE} + ${IMAGE_ROOTFS_ALIGNMENT} - 1)
BOOT_SPACE_ALIGNED=$(expr ${BOOT_SPACE_ALIGNED} - ${BOOT_SPACE_ALIGNED} % ${IMAGE_ROOTFS_ALIGNMENT})
ROOTFS_SIZE=`du -bksL ${SDIMG_ROOTFS} | awk '{print $1}'`
# Round up RootFS size to the alignment size as well
ROOTFS_SIZE_ALIGNED=$(expr ${ROOTFS_SIZE} + ${IMAGE_ROOTFS_ALIGNMENT} - 1)
ROOTFS_SIZE_ALIGNED=$(expr ${ROOTFS_SIZE_ALIGNED} - ${ROOTFS_SIZE_ALIGNED} % ${IMAGE_ROOTFS_ALIGNMENT})
SDIMG_SIZE=$(expr 4  \* ${IMAGE_ROOTFS_ALIGNMENT} + ${BOOT_SPACE_ALIGNED} + 3 \* ${ROOTFS_SIZE_ALIGNED})
echo "Creating filesystem with Boot partition ${BOOT_SPACE_ALIGNED} KiB and RootFS ${ROOTFS_SIZE_ALIGNED} KiB"

# Initialize sdcard image file
dd if=/dev/zero of=${SDIMG} bs=1024 count=0 seek=${SDIMG_SIZE}
# Creat  partition table
 parted -s ${SDIMG} mklabel msdos
# Create boot partition and mark it as bootable
 parted -s ${SDIMG} unit KiB mkpart primary fat32 ${IMAGE_ROOTFS_ALIGNMENT} $(expr ${BOOT_SPACE_ALIGNED} \+ ${IMAGE_ROOTFS_ALIGNMENT})
 parted -s ${SDIMG} set 1 boot on
# Create rootfs STD partition 
 parted -s ${SDIMG} unit KiB mkpart primary ext2 $(expr ${BOOT_SPACE_ALIGNED} \+ ${IMAGE_ROOTFS_ALIGNMENT}) $(expr ${BOOT_SPACE_ALIGNED} \+ ${IMAGE_ROOTFS_ALIGNMENT} \+ ${ROOTFS_SIZE_ALIGNED}) 
#Create rootfs PREEMPT partition 
 parted -s ${SDIMG} unit KiB mkpart primary ext2 $(expr ${BOOT_SPACE_ALIGNED} \+  2 \* ${IMAGE_ROOTFS_ALIGNMENT} \+ ${ROOTFS_SIZE_ALIGNED}) $(expr ${BOOT_SPACE_ALIGNED} \+  2 \* ${IMAGE_ROOTFS_ALIGNMENT} \+ 2 \* ${ROOTFS_SIZE_ALIGNED}) 
# Create rootfs XENOMAI partition 
 parted -s ${SDIMG} unit KiB mkpart  primary ext2 $(expr ${BOOT_SPACE_ALIGNED} \+  3 \* ${IMAGE_ROOTFS_ALIGNMENT} \+ 2 \* ${ROOTFS_SIZE_ALIGNED}) $(expr ${BOOT_SPACE_ALIGNED} \+ 3 \* ${IMAGE_ROOTFS_ALIGNMENT} \+ 3 \* ${ROOTFS_SIZE_ALIGNED}) 

# Create a vfat image with boot files
BOOT_BLOCKS=$(LC_ALL=C parted -s ${SDIMG} unit b print | awk '/ 1 / { print substr($4, 1, length($4 -1)) / 512 /2 }')
mkfs.vfat -n "Boot" -S 512 -C ${CURRENT_DIR}/boot.img $BOOT_BLOCKS

# Update cmdline.txt with optional boot params
shift
#Set starting partition number for ROOTFS
part_num=2;
#Copy RPI startup files
mcopy -i ${CURRENT_DIR}/boot.img  -s ${CURRENT_DIR}/rpi-firmware/bootcode.bin ::/
mcopy -i ${CURRENT_DIR}/boot.img  -s ${CURRENT_DIR}/rpi-firmware/start.elf ::/
mcopy -i ${CURRENT_DIR}/boot.img  -s ${CURRENT_DIR}/rpi-firmware/fixup.dat ::/
mcopy -i ${CURRENT_DIR}/boot.img  -s ${CURRENT_DIR}/rpi-firmware/config.txt ::/

for i in $(ls ${CURRENT_DIR} | grep RASP_); do
cmdline="$(cat $CURRENT_DIR/../../board/raspberrypi/cmdline.txt)"
cmdline+=" root=/dev/mmcblk0p$part_num rootwait"
echo $cmdline > ${CURRENT_DIR}/$i/cmdline.$i
# Copy boot files
if [[ $i == *"STD"* ]]
then
  # Copy default cmdline
  mcopy -i ${CURRENT_DIR}/boot.img -s ${CURRENT_DIR}/$i/cmdline.$i ::/cmdline.txt
  # Copy default kernel
  mcopy -i ${CURRENT_DIR}/boot.img -s ${CURRENT_DIR}/$i/zImage ::zImage
  echo chosed as default : $i
fi
# Copy  cmdline
mcopy -i ${CURRENT_DIR}/boot.img -s ${CURRENT_DIR}/$i/cmdline.$i ::/
# Copy kernel
mcopy -i ${CURRENT_DIR}/boot.img -s ${CURRENT_DIR}/$i/zImage ::zImage.$i
part_num=$(expr $part_num \+ 1)
done
# Burn Partitions
dd if=${CURRENT_DIR}/boot.img of=${SDIMG} conv=notrunc seek=1 bs=$(expr ${IMAGE_ROOTFS_ALIGNMENT} \* 1024) && sync && sync
num=1
for k in $(ls ${CURRENT_DIR} | grep RASP_) ;do
dd if=${CURRENT_DIR}/$k/rootfs.${SDIMG_ROOTFS_TYPE} of=${SDIMG} conv=notrunc seek=1 bs=$(expr 1024 \* ${BOOT_SPACE_ALIGNED} +  ${IMAGE_ROOTFS_ALIGNMENT} \* 1024 \* $num \+ 1024 \* $(expr $num \- 1) \* ${ROOTFS_SIZE_ALIGNED}) && sync && sync
num=$(expr $num \+ 1)
done;
rm -f ${CURRENT_DIR}/boot.img
echo
echo "**** Done."
echo "You just have to do 'dd if=$(basename ${SDIMG}) of=<SD card device>'"
echo 
