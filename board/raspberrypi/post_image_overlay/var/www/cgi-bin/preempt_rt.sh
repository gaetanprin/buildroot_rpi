#!/bin/bash
echo "Content-type: text/html"
echo ""
echo "Copy : cmdline preempt_rt  --> /boot/cmdline.txt"
echo "<br>"
sudo cp /boot/$(ls /boot/ | grep -i cmdline | grep -i preempt | tr -d "*") /boot/cmdline.txt
echo "Copy : zImage preempt rt --> /boot/zImage"
echo "<br>"
sudo cp /boot/$(ls /boot/ | grep -i zImage | grep -i preempt | tr -d "*") /boot/zImage
echo "Start reboot"
sudo reboot
