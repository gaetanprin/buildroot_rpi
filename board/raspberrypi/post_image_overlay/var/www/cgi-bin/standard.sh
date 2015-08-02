#!/bin/bash
echo "Content-type: text/html"
echo ""
echo "Copy : /boot/cmdline_standard.txt --> /boot/cmdline.txt"
echo "<br>"
sudo cp /boot/cmdline_std.txt /boot/cmdline.txt
echo "Copy : /boot/zImage_standard --> /boot/zImage"
echo "<br>"
sudo cp /boot/zImage_std /boot/zImage
echo "Start reboot"
sudo reboot
