#!/bin/bash

echo "Launch of automatic installation of arch script..."

loadkeys fr
ls /sys/firmware/efi/efivars > /dev/null
if [ $? -eq 0 ] ; then
    echo "efi systeme"
    system="efi"
else
    echo "BIOS systeme"
    system="bios"
fi

echo "pingging archlinux.org ...."
if [ "`ping -c 1 archlinux.org`" ];then
  echo "ping success"
else
  echo "ping failed.."
  exit 1
fi

timedatectl set-ntp true

#!--------------------------------------Disk choice----------------------------------------!#
diskchoice()
{
i=-1
for diskname in $(lsblk -o NAME)
do  
    if [ $i = $1 ];then
        DISKID="$diskname"
    fi
    i=$((i + 1))
done
}

COUNT=0
 for i in $(lsblk -o NAME)
do
       COUNT=$[COUNT+1]
       MENU_OPTIONS[$COUNT]="$i"
done

option=""
COUNT=0
j=0
while [ $COUNT -lt ${#MENU_OPTIONS[*]} ]
do
  if [ $COUNT -ne 0 ] && [ $COUNT -ne 1 ];then
    
    j=$[j+1]
    option="$option $j ${MENU_OPTIONS[$COUNT]}"
  fi
  COUNT=$[COUNT+1]
done

DISKID=$(\
dialog --title "Disk Choice"\
 --menu "choose on which disk you want to install archlinux : "  20 70 10 \
 $option 3>&1 1>&2 2>&3 3>&- )

DISK=${MENU_OPTIONS[$DISKID+1]}

#echo "you choose the disk ${DISK}"


#!--------------------------------------Partition----------------------------------------!#

COUNT=0
 for i in $(lsblk -o SIZE)
do
       COUNT=$[COUNT+1]
       TABSIZE[$COUNT]="$i"
done

DISKSIZE=${TABSIZE[$DISKID+1]} 

dialog --title "SWAP"  --yesno "Do you want a SWAP partition ?" 10 60 3>&1 1>&2 2>&3 3>&- 
swap=$?


case $swap in
   0)  swapsize=$(dialog --title "Swap Size" \
      --backtitle "Size of the disk: $DISKSIZE" \
      --inputbox "Enter a size for the swap partition (ex: 512M or 1G)" 8 60 3>&1 1>&2 2>&3 3>&- )
       ;;
     
   1) swapsize="no" ;;
   255) exit ;;
esac

dialog --title "/"  --yesno "Do you want a \"/\" partition ?" 10 60 3>&1 1>&2 2>&3 3>&- 
rootpartition=$?

case $rootpartition in
   0) sizerootpartition=$(dialog --title "/ Size" \
      --backtitle "Size of the disk: $DISKSIZE , size of the swap: $swapsize" \
      --inputbox "Enter a size for the / partition (ex: 512M or 1G)" 8 60  3>&1 1>&2 2>&3 3>&- ) ;;
   1) sizerootpartition="no" ;;
   255) exit 1;;
esac

dialog --title "/home"  --yesno "Do you want a \"/home\" partition ?" 10 60 3>&1 1>&2 2>&3 3>&- 
homepartition=$?

case $homepartition in
   0) sizehomepartition=$(dialog --title "/home Size" \
      --backtitle "Size of the disk \: $DISKSIZE , size of the swap: $swapsize, size of the / partition $sizerootpartition" \
      --inputbox "Enter a size for the /home partition (ex: 512M or 1G)"  8 60 3>&1 1>&2 2>&3 3>&- ) ;;
   1) sizehomepartition="no" ;;
   255) exit 1;;
esac

echo "$swapsize"
echo "$sizerootpartition"
echo "$sizehomepartition"

echo ${swapsize%?}
echo ${sizerootpartition%?}
echo ${sizehomepartition%?}


echo ${swapsize: -1}
echo ${sizerootpartition: -1}
echo ${sizehomepartition: -1}
