#!/bin/bash

echo "Launch of automatic installation of arch script..."

loadkeys fr
sys= $(ls /sys/firmware/efi/efivars)
if [ $sys -ne "ls: cannot access '/sys/firmware/efi/efivars': No such file or directory"]; then
    echo "efi systeme"
    $system="efi"
else
    echo "BIOS systeme"
    $system="bios"
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
$i=1
for diskname in $(lsblk -o NAME)
do
    if [ $i = $1 ];then
        ${DISK} = $diskname
    else
        $i=$i+1
done
}

$i=1
for diskname in $(lsblk -o NAME)
do
echo "$i"
echo "$diskname"
$i=$i+1
done

echo -e "choose on which disk you want to install archlinux : "

read choice

case $choice in
  1) $disk = diskchoice "1" 
  2) $disk = diskchoice "2"
  3) $disk = diskchoice "3"
  *) echo "ERROR"
esac
