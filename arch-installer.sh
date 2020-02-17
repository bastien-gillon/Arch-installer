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
        DISK="$diskname"
    fi
    i=$((i + 1))
done
}

#i=0
#for diskname in $(lsblk -o NAME)
#do
#  if [ $i != 0 ];then 
#        #echo "$i) $diskname"
#        disk[$i]="$diskname"
#  fi

#i=$((i + 1))
#done
 
 for i in `lsblk -o NAME`
do
       COUNT=$[COUNT+1]
       MENU_OPTIONS="${MENU_OPTIONS} ${COUNT} $i off "
done


cmd=(dialog --separate-output --menu "Select options:" 22 76 16)
options=(${MENU_OPTIONS})
choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
for choice in $choices
do
       case $choice in
        1)
            echo "First Option"
            ;;
        2)
            echo "Second Option"
            ;;
        3)
            echo "Third Option"
            ;;
        4)
            echo "Fourth Option"
            ;;
    esac
done


# echo -e "choose on which disk you want to install archlinux : "

#read choiceD

#!case $choiceD in
#  "1") diskchoice "0" ;;
#  "2") diskchoice "1";;
#  "3") diskchoice "2";;
#  "4") diskchoice "3";;
#  "5") diskchoice "4";;
#  *) echo "ERROR";;
#esac

#echo "you choose the disk ${DISK}"


#!--------------------------------------Partition----------------------------------------!#

#if [ $system = efi ];then 
#  echo -e "Do you want a SWAP partition [y/n]"
#  
#  read choiceS
# 
#  if [ choiceS = "y" || choiceS = "Y" ], then
#        echo -e "Enter the size of the partition "
  
#  else
  
  
#  fi
#fi