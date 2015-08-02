#!/bin/bash
echo "Content-type: text/html"
echo ""
echo "Copy : /boot/cmdline_xenomai.txt --> /boot/cmdline.txt"
echo "<br>"
sudo cp /boot/cmdline_xenomai.txt /boot/cmdline.txt
echo "Copy : /boot/zImage_xenomai --> /boot/zImage"
echo "<br>"
sudo cp /boot/zImage_xenomai /boot/zImage
echo "Start reboot"
sudo reboot
