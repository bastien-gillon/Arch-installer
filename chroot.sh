COUNT=0
zoneinfo=""
cd /usr/share/zoneinfo
tmp = ls -d -- */
echo $tmp
for i in $tmp
do
COUNT=$[COUNT+1]
  zoneinfo="$zoneinfo $COUNT $i"
done
 echo "----------------"
 echo $zoneinfo
 echo "----------------"

ZONE=$(\
dialog --title "Disk Choice"\
 --menu "choose your zone : "  20 70 10 \
 $zoneinfo 3>&1 1>&2 2>&3 3>&- )


echo "$ZONE"

exit
