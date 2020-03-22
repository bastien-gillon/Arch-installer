COUNT=0
zoneinfo=""
for i in $(ls /usr/share/zoneinfo/)
do
  zoneinfo="$zoneinfo $i"
  COUNT=$[COUNT+1]
done

ZONE=$(\
dialog --title "Disk Choice"\
 --menu "choose your zone : "  20 70 10 \
 $zoneinfo 3>&1 1>&2 2>&3 3>&- )


echo "$ZONE"
exit
