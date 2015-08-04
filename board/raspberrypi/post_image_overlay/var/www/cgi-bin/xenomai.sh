#!/bin/bash
echo "Content-type: text/html"
echo ""
echo "Copy : cmdline xenomai --> /boot/cmdline.txt"
echo "<br>"
sudo cp /boot/$(ls /boot/ | grep -i cmdline | grep -i xenomai | tr -d "*") /boot/cmdline.txt
echo "Copy : zImage xenomai --> /boot/zImage"
echo "<br>"
sudo cp /boot/$(ls /boot/ | grep -i zimage | grep -i xenomai | tr -d "*") /boot/zImage
echo "Start reboot"
sudo reboot
