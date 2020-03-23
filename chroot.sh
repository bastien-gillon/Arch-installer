COUNT=0
zoneinfo=""
cd /usr/share/zoneinfo
tmp=$(ls -d -- */)
echo $tmp
for i in $tmp
do
COUNT=$[COUNT+1]
  zoneinfo="$zoneinfo $COUNT $i"
  TABZONE[$COUNT]=$i
done

ZONE=$(\
dialog --title "Disk Choice"\
 --menu "choose your zone : "  20 70 10 \
 $zoneinfo 3>&1 1>&2 2>&3 3>&- )



cd /usr/share/zoneinfo/TABZONE[$ZONE]
region=""
echo $tmp
for i in $(ls)
do
COUNT=$[COUNT+1]
  region="$region $COUNT $i"
  TABZONE[$COUNT]=$i
done

echo TABZONE[$ZONE]
echo TABZONE[$region]

exit
