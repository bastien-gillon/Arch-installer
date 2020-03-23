COUNT=0
zoneinfo=""
cd /usr/share/zoneinfo
for i in 'ls -d -- */ '
do
COUNT=$[COUNT+1]
  zoneinfo="$zoneinfo $COUNT $i"
done


ZONE=$(\
dialog --title "Disk Choice"\
 --menu "choose your zone : "  20 70 10 \
 $zoneinfo 3>&1 1>&2 2>&3 3>&- )


echo "$ZONE"

exit
