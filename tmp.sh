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
echo "git clone https://github.com/bastien-gillon/arch-installer" 
echo "cd arch-installer"
echo "bash chroot.sh"
echo "rm -r arch-installer"
) | arch-chroot /mnt 

