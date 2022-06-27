#!/bin/bash
# 2021.04.20 - v. 0.1 - zmiana, by bylo jedno tylko pytanie o haslo
# 2020.xx.xx - v. 0.1 - initial release

. /root/bin/_script_header.sh

loc_dir_name="/mnt/rsync-master-_na_DVD"
rem_dir_name="//laptopvm.eth.b.matuszyk.com/_na_DVD-MASTER-SOURCE"

set +x 

echo 
echo 
echo  server 
echo 
echo 

#set -x

read -p "Wpisz haslo: " -s PASSWD

umount "${loc_dir_name}" 2>/dev/null  # just in case sa zamontowane, by nie dostawac komunikatu "mount error(16): Device or resource busy"

mount.cifs -o user=p,password=$PASSWD "${rem_dir_name}" "${loc_dir_name}" 
df -hP "${loc_dir_name}"

# set +x

. /root/bin/_script_footer.sh
