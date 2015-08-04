#!/bin/bash
echo "Content-type: text/html"
echo ""
echo "Copy :  cmdline standard  --> /boot/cmdline.txt"
echo "<br>"
sudo cp /boot/$(ls /boot/ | grep -i cmdline | grep -i std | tr -d "*") /boot/cmdline.txt
echo "Copy : /boot/zImage_standard --> /boot/zImage"
echo "<br>"
sudo cp /boot/$(ls /boot/ | grep -i zimage | grep -i std | tr -d "*") /boot/zImage
echo "Start reboot"
sudo reboot
