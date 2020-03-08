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
pacman -Sy pv | echo "y"
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

if dialog --stdout --title "Disk Choice" \
          --yesno "Are you sure you want to choose this ${DISK} ? Everything will be erased on this disc" 20 40; 
then
 #!--------------------------------------Partition----------------------------------------!#
 
(pv -n /dev/zero | dd of=/dev/${DSIK} bs=1M conv=notrunc,noerror) 2&gt;&amp;1 | dialog --gauge "Running dd command (erasing ${DISK}), please wait..." 10 70 0
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
   1) swapsize=0 ;;
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

  parted /dev/$DISK mklabel gpt 
  parted /dev/$DISK mkpart ESP fat32 0 1G

  if [ $swap -eq 0 ];then

   tmp="G"
   swapsize=${swapsize%?}
   swapsize=$[swapsize+1]
   swapsize=$swapsize$tmp

   sizerootpartition=${sizerootpartition%?}
   sizerootpartition=$[sizerootpartition+1]
   sizerootpartition=$sizerootpartition$tmp

   
   parted /dev/$DISK mkpart primary linux-swap 1G $swapsize
   parted /dev/$DISK mkpart primary ext4  $swapsize  $sizerootpartition
   parted /dev/$DISK mkpart primary ext4  $sizerootpartition 100%

   $tmp1=1
   $tmp2=2
   $tmp3=3
   $tmp4=4
   $disk1=$DISKID$tmp1
   $disk2=$DISKID$tmp2
   $disk3=$DISKID$tmp3
   $disk4=$DISKID$tmp4
   
   mkswap /dev/$disk2
   swapon /dev/$disk2
   mkfs.vfat -F32 /dev/$disk1 #boot
   mkfs.ext4 /dev/$disk3	    #"/"
   mkfs.ext4 /dev/$disk4	    #home

  else 

    tmp="G"

    sizerootpartition=${sizerootpartition%?}
    sizerootpartition=$[sizerootpartition+1]
    sizerootpartition=$sizerootpartition$tmp

    parted /dev/$DISK mkpart primary ext4  1G  $sizerootpartition
    parted /dev/$DISK mkpart primary ext4  $sizerootpartition 100%

    $tmp1="1"
    $tmp2="2"
    $tmp3="3"

    $disk1=$DISKID$tmp1
    $disk2=$DISKID$tmp2
    $disk3=$DISKID$tmp3
    
    mkfs.vfat -F32 /dev/$disk1 #boot
    mkfs.ext4 /dev/$disk2	    #"/"
    mkfs.ext4 /dev/$disk3	    #home
    
  fi
    
fi
else
    exit;
fi






