#!/bin/bash

echo "Launch of automatic installation of arch script..."


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


sizerootpartition=$(dialog --title "/ Size" \
   --backtitle "Size of the disk: $DISKSIZE , size of the swap: $swapsize" \
   --inputbox "Enter a size for the / partition ( Suggested size: 23-32G )" 8 80  3>&1 1>&2 2>&3 3>&- ) 

#sizehomepartition=$(dialog --title "/home Size" \
#   --backtitle "Size of the disk \: $DISKSIZE , size of the swap: $swapsize, size of the / partition $sizerootpartition" \
#   --inputbox "Enter a size for the /home partition "  8 60 3>&1 1>&2 2>&3 3>&- ) 




## only numbers

echo ${swapsize%?}
echo ${sizerootpartition%?}
#echo ${sizehomepartition%?}

## only Letter

echo ${swapsize: -1}
echo ${sizerootpartition: -1}
#echo ${sizehomepartition: -1} 

tmp=${swapsize%?}
if [ ${swapsize: -1} == "M" ] || [ ${swapsize: -1} == "m" ];then 

   # to do parted when swap in M
   bc -l <<< "scale=3; ${tmp}/1000"
   swapsize=$?
   tmp="G"
   swapsize=$swapsize$tmp

fi

echo "$swapsize"
echo "$sizerootpartition"
#echo "$sizehomepartition"

if [ $system == "efi" ];then

   parted /dev/$DISK mklabel gpt | yes 
   exit 
   parted /dev/$DISK | mkpart ESP fat32 0 1G	
   swapsize=${swapsize%?}
   parted /dev/$DISK | mkpart primary linux-swap 1G $[swapsize+1]
   
fi
exit  
   mkpart ESP fat32 0 1G				#boot
   mkpart primary linux-swap 1G $[{swapsize%?}+1]	#swap
   mkpart primary ext4 $[{swapsize%?}+1]  $[{sizerootpartition%?}+1]		#"/"
   mkpart primary ext4 $[{sizerootpartition%?}+1]  100%		#home

   quit 

   mkfs.vfat -F32 /dev/sda1 #boot
   mkfs.ext4 -f /dev/sda3	 #"/"
   mkfs.ext4 -f /dev/sda4	 #home
fi

