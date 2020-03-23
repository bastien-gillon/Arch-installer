COUNT=0
zoneinfo=""

##-----------CHOICE OF ZONE-----------#
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


##-----------CHOICE OF REGION-----------#
cd /usr/share/zoneinfo/TABZONE[$ZONE]
region=""
echo $tmp
for i in $(ls)
do
COUNT=$[COUNT+1]
  region="$region $COUNT $i"
  TABREGION[$COUNT]=$i
done
REGION=$(\
dialog --title "Disk Choice"\
 --menu "choose your zone : "  20 70 10 \
 $region 3>&1 1>&2 2>&3 3>&- )


echo $(TABZONE[$ZONE])
echo $(TABREGION[$REGION])

exit
