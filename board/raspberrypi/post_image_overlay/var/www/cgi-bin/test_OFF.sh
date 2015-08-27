#!/bin/bash
echo "Content-type: text/html"
echo ""
echo Setting gpio OFF
sudo killall -9 rpi_gpio
