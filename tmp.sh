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
    mount /dev/${NBDISK[4]}	/mnt/home
  else
    mount /dev/${NBDISK[4]} /mnt/
    mkdir /mnt/boot
    mkdir /mnt/home
    mount /dev/${NBDISK[2]} /mnt/boot
    mount /dev/${NBDISK[5]}	/mnt/home

  fi


(
echo "sleep 3"
) | arch-chroot /mnt 

umount -R /mnt

echo "\n before \n"

sleep 3
dialog --title "Reboot"  --msgbox "your installation is finished. Your pc will reboot ..." 10 30

echo "================="
echo "| DOBBY IS FREE |"
echo "================="

