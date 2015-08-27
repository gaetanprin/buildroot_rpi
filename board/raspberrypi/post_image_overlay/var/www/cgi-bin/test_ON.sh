#!/bin/bash
echo "Content-type: text/html"
echo ""
echo Setting new frequency
echo period : $1
sudo rpi_gpio -p $1 &
