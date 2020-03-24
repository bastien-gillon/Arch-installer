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
    
  fi

  MachineName=$(dialog --title "Machine Name" --inputbox "Enter your machine name:" 8 40)
  passwd=""
  passwdcheck="-1"

  ################################ DON'T  WORK ####################################################
  while [ "$passwd" != "$passwdcheck" ]
  do
  dialog --title "Password" \
  --clear \
  --insecure \
  --passwordbox "Enter your password" 10 30 2> $passwd
  ##############################################################
  exit
  
(
echo "rm -r arch-installer"
echo "git clone https://github.com/bastien-gillon/arch-installer" ;
echo "cd arch-installer"
echo "bash chroot.sh"
) | arch-chroot /mnt 

umount -R /mnt
dialog --title "Reboot" --msgbox  'your installation is finished. Your pc will restart ... ' 6 20

reboot