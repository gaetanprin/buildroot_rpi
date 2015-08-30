#!/bin/bash
echo "Content-type: text/html"
echo ""
echo Setting gpio OFF

#Save the old internal field separator.
OIFS="$IFS"
#Set the field separator to & and parse the QUERY_STRING at the ampersand.
IFS="${IFS}&"
set $QUERY_STRING
Args="$*"
if [ -z "$Args" ]; then 
 echo no arg provided !
 exit
fi
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
              # Filter for "/" not applied here
              linux_mode) ARG2="`echo $2 | sed 's|%20| |g'`"
                     ;;
              *)     echo "<hr>Warning:"\
                          "<br>Unrecognized variable \'$1\' passed by FORM in QUERY_STRING.<hr>"
                     ;;
      esac
done

if [ "$ARG2" != "Xenomai" ]; then
 echo Killing $ARG2 process
 sudo killall rpi_gpio
 exit 1
fi

sudo killall xenomai_rpi_gpio
