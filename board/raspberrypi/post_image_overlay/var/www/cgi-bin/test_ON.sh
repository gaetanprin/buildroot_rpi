#!/bin/bash
echo "Content-type: text/html"
echo ""
echo Setting new frequency

#Save the old internal field separator.
OIFS="$IFS"
#Set the field separator to & and parse the QUERY_STRING at the ampersand.
IFS="${IFS}&"
set $QUERY_STRING
Args="$*"
IFS="$OIFS"
#Next parse the individual "name=value" tokens.
ARGX=""
ARGY=""
ARGZ=""
for i in $Args ;do
	 
      #Set the field separator to =
      IFS="${OIFS}="
      set $i
      IFS="${OIFS}"
      case $1 in
              # Don't allow "/" changed to " ". Prevent hacker problems.
              period)ARG1="`echo $2 | sed 's|[\]||g' | sed 's|%20| |g' | sed 's|%20| |g'`"
                     ;;
              # Filter for "/" not applied here
              linux_mode) ARG2="`echo $2 | sed 's|%20| |g' | sed 's|%20| |g'`"
                     ;;
              gpio) ARG3="`echo $2 | sed 's|%20| |g'`"
                     ;;
	      *)     echo "<hr>Warning:"\
                          "<br>Unrecognized variable \'$1\' passed by FORM in QUERY_STRING.<hr>"
                     ;;
      esac
done

echo arg1 = $ARG1
echo arg 2 = $ARG2
echo arg3 = $ARG3
if [ "$ARG2" != "Xenomai" ]; then
 echo No xenomai
 if [ ! -z $ARG3 ];then
  echo unloading driver
  sudo killall rpi_gpio
  sudo rmmod /lib/modules/$(uname -r)/rpi_gpio_drv.ko
  sudo insmod /lib/modules/$(uname -r)/rpi_gpio_drv.ko gpio_nr=$ARG3
  if [ $? -ne 0 ];then
   echo GPIO number not corect ! Cannot load driver...
   exit 1
  fi 
 fi
 echo starting rpi_gpio
 echo sudo rpi_gpio -p $ARG1 &
 sudo rpi_gpio -p $ARG1 &
 exit 1
fi;

sudo xenomai_rpi_gpio -p $ARG1 -g $ARG3
