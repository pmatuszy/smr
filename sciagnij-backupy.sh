#!/bin/bash

# 2023.03.13 - v. 0.1 - initial release

. /root/bin/_script_header.sh

if [ -f "$HEALTHCHECKS_FILE" ];then
  HEALTHCHECK_URL=$(cat "$HEALTHCHECKS_FILE" |grep "^`basename $0`"|awk '{print $2}')
fi

if [ ! -z "${HEALTHCHECKS_FORCE_ID:-}" ]; then
  HEALTHCHECK_URL=$(cat "$HEALTHCHECKS_FILE" |grep "^$HEALTHCHECKS_FORCE_ID"|awk '{print $2}')
fi

if [ -f $HOME/.keychain/$HOSTNAME-sh ];then
  . $HOME/.keychain/$HOSTNAME-sh
fi

check_if_installed curl
check_if_installed rsync
check_if_installed scp openssh-client

if (( $# != 2 )) ; then
  echo ; echo "(PGM) wrong # of command line arguments... (must be exactly 2)" ; echo 
  exit 1
fi

if [ ! -d "${@:$#}" ];then
  echo ; echo "(PGM) Directory ${@:$#} doesn't exist..." ; echo
  exit 2
fi

export SKAD=$1
export DOKAD="$2"

#### export rsync_option="-a -v --stats --bwlimit=990000 --no-compress --progress --info=progress1 --partial  --inplace --remove-source-files"

export rsync_options="-a -v --stats --bwlimit=990000 --no-compress --partial  --inplace "

HC_MESSAGE=$(
   cat  $0|grep -e '# *20[123][0-9]'|head -n 1 | awk '{print "script version: " $5 " (dated "$2")"}'
   echo ; echo "aktualna data: `date '+%Y.%m.%d %H:%M'`" ; echo ;
   
   echo ; echo  ; echo "SKAD  = $SKAD" ; echo "DOKAD = $DOKAD" ; echo 
   echo ; echo "command to be run:"
   echo rsync $rsync_options ${SKAD} "${DOKAD}"
   eval rsync $rsync_options ${SKAD} "${DOKAD}"
   exit $?
   )
kod_powrotu=$?

if (( $script_is_run_interactively == 1 )); then
  echo "$HC_MESSAGE"
fi

echo "$HC_MESSAGE" | /usr/bin/curl -fsS -m 100 --retry 10 --retry-delay 10 --data-binary @- -o /dev/null "$HEALTHCHECK_URL"/$kod_powrotu 2>/dev/null

exit $?
