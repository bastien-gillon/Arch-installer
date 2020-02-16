#!/bin/bash

echo "Launch of automatic installation of arch script..."

loadkeys fr
ls /sys/firmware/efi/efivars 
if [ $? -eq 0 ] ; then
    echo "efi systeme"
    $system = "efi"
else
    echo "BIOS systeme"
    $system = "bios"
fi

echo "pingging archlinux.org ...."
if [ "`ping -c 1 archlinux.org`" ];then
  echo "ping success"
else
  echo "ping failed.."
  exit 1
fi

timedatectl set-ntp true

diskchoice()
{
i=1
for diskname in $(lsblk -o NAME)
do
    if [ $i = $1 ];then
        DISK = $diskname
    else
        i=$((i + 1))
    fi
done
}

$i=1
for diskname in $(lsblk -o NAME)
do
echo "$i) $diskname"

i=$((i + 1))
done

echo -e "choose on which disk you want to install archlinux : "

read choice

case $choice in
  "1") diskchoice "1" ;;
  "2") diskchoice "2";;
  "3") diskchoice "3";;
  *) echo "ERROR";;
esac

echo "you choose the disk ${DISK}"
