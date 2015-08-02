#!/bin/bash
echo "Content-type: text/html"
echo ""
echo "Copy : /boot/cmdline_preempt_rt.txt --> /boot/cmdline.txt"
echo "<br>"
sudo cp /boot/cmdline_preempt_rt.txt /boot/cmdline.txt
echo "Copy : /boot/zImage_preempt_rt --> /boot/zImage"
echo "<br>"
sudo cp /boot/zImage_preempt_rt /boot/zImage
echo "Start reboot"
sudo reboot
