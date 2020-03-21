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
pacman -Sy pv --noconfirm
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
          --yesno "Are you sure you want to choose \" ${DISK} \"? Everything will be erased on this disc" 10 60; 
then
 #!--------------------------------------Partition----------------------------------------!#

# ( dd if=/dev/zero | pv -n /dev/${DISK} | dd of=/dev/${DISK} bs=4096 ) 2>&1 | dialog --gauge "Running dd command (erasing ${DISK}), please wait..." 10 70 0



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

## only numbers
#${swapsize%?}
#${sizerootpartition%?}

## only Letter
#${swapsize: -1}
#${sizerootpartition: -1}

tmp=${swapsize%?}
if [ ${swapsize: -1} == "M" ] || [ ${swapsize: -1} == "m" ];then 

   # to do check if we got G 
   bc -l <<< "scale=3; ${tmp}/1000"
   swapsize=$?
   tmp="G"
   swapsize=$swapsize$tmp

fi

tmp="+"
swapsize=$tmp$swapsize
sizerootpartition=$tmp$sizerootpartition

echo "$swapsize"
echo "$sizerootpartition"

if [ $system == "efi" ];then

  (#-----boot----#
  echo g
  echo n
  echo ""
  echo ""
  echo +512M
  echo t
  echo 1 #efi label

  #----swap-----#

    if [ $swap -eq 0 ];then 

      echo n
      echo ""
      echo ""
      echo $swapsize
      echo t
      echo ""
      echo 19 #swap label

    fi

    #----root----#

    echo n
    echo ""
    echo ""
    echo $sizerootpartition
    echo t
    echo ""
    echo 24 #linux x86_64 label 

    #----home----#

    echo n
    echo ""
    echo ""
    echo ""
    echo t
    echo ""
    echo 24 #linux x86_64 label

    echo w ) | fdisk /dev/sda


    #mkswap /dev/$disk2
    #swapon /dev/$disk2
    #mkfs.vfat -F32 /dev/$disk1 #boot
    #mkfs.ext4 /dev/$disk3	    #"/"
    #mkfs.ext4 /dev/$disk4	    #home

        
    fi
else
   ## TO DO BIOS PARTITION
    exit;
fi






