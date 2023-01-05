#!/bin/bash

# 2023.01.05 - v. 0.3 - added detection of ST18000NM000J-2TV103 drives as Seagate ones
# 2022.12.20 - v. 0.2 - now printing info about the disk as well
# 2022.10.11 - v. 0.1 - initial release

# exit when your script tries to use undeclared variables
set -o nounset
set -o pipefail
# if we are run non-interactively - do not set the terminal title
export tcScrTitleStart="\ek"
export tcScrTitleEnd="\e\134"

if [ ! -z ${STY:-} ]; then    # checking if we are running within screen
  # I am setting the screen window title to the script name
  echo -ne "${tcScrTitleStart}${0}${tcScrTitleEnd}"
fi

echo ; echo ; cat  $0|grep -e '# *20[123][0-9]'|head -n 1 | awk '{print "script version: " $5 " (dated "$2")"}' ; echo 

if [ $# -eq 0 ]
  then
    echo ; echo ; echo "No arguments supplied, I will run the script against ALL disks found on this systems..."
    echo "searching for disks..."
    disks=$(jd.sh |grep Disk |sed 's|:.*||g'|sed 's|Disk ||g')
else
  disks=$1
fi

DEVICE_TYPE=""
VENDOR_ATTRIBUTE=""
SUBCOMMAND="--info -A "
export SMARTCTL_BIN=$(type -fP smartctl)

for p in $disks ; do
  echo;echo
  echo $p | boxes -s 40x5 -a c ; echo

  $SMARTCTL_BIN  --info $p 2>&1 > /dev/null
  
  if (( $? == 1 ));then 
    DEVICE_TYPE='-d sat'
  fi

  $SMARTCTL_BIN $DEVICE_TYPE --info $p 2>&1 > /dev/null
  if (( $? == 1 ));then 
    echo  ; echo "I don't know which device type (-d), so I am quitting" ; echo ; echo exit 1 ; echo 
    exit 1
  fi

  $SMARTCTL_BIN $DEVICE_TYPE --info $p 2>&1 > /dev/null
  if (( $? == 2 ));then
    echo  ; echo "No such a device, I am exiting " ; echo ; echo exit 2 ; echo
    exit 2
  fi

  czy_seagate=$($SMARTCTL_BIN  $DEVICE_TYPE --info $p|egrep -i 'seagate|ST18000NM000J' | wc -l)
  if (( $czy_seagate > 0 ));then
    VENDOR_ATTRIBUTE="-v 1,raw48:54 -v 7,raw48:54 -v 187,raw48:54  -v 188,raw48:54 -v 195,raw48:54"
    echo "* * * * * * This is Seagate drive (PGM) * * * * * *"
  fi 
  $SMARTCTL_BIN $DEVICE_TYPE $VENDOR_ATTRIBUTE $SUBCOMMAND $p
done
