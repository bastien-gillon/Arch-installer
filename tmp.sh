DISK="sda"
COUNT=0
for i in $(lsblk -o NAME -l | grep $DISK )
  do
       COUNT=$[COUNT+1]
       NBDISK[$COUNT]="$i"
  done

  if [ $(lsblk -o NAME | grep $DISK | wc -l) -eq 4 ];then
    
    mount /dev/${NBDISK[3]} /mnt/
    mkdir /mnt/boot
    mkdir /mnt/home
    mount /dev/${NBDISK[2]} /mnt/boot
    echo "-------------------"
    mount /dev/${NBDISK[4]}	/mnt/home
    
 
  fi


cd /mnt
mount -t proc proc proc/
mount --rbind /sys sys/
mount --rbind /dev dev/

Puis :

chroot /mnt /bin/bash
arch-chroot /mnt
COUNT=0
zoneinfo=""
for i in $(ls /usr/share/zoneinfo/)
do
  zoneinfo="$zoneinfo $i"
  COUNT=$[COUNT+1]
done

ZONE=$(\
dialog --title "Disk Choice"\
 --menu "choose your zone : "  20 70 10 \
 $zoneinfo 3>&1 1>&2 2>&3 3>&- )


echo "$ZONE"
umount -R /mnt