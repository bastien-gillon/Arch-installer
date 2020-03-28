

##-----------CHOICE OF ZONE-----------#
COUNT=0
zoneinfo=""
cd /usr/share/zoneinfo
tmp=$(ls -d -- */)
echo $tmp
for i in $tmp
do
COUNT=$[COUNT+1]
  zoneinfo="$zoneinfo $COUNT $i"
  TABZONE[$COUNT]=$i
done

ZONE=$(\
dialog --title "Zone Choice"\
 --menu "choose your zone : "  20 70 10 \
 $zoneinfo 3>&1 1>&2 2>&3 3>&- )


##-----------CHOICE OF REGION-----------#
cd /usr/share/zoneinfo/${TABZONE[$ZONE]}
region=""
for i in $(ls)
do
COUNT=$[COUNT+1]
  region="$region $COUNT $i"
  TABREGION[$COUNT]=$i
done
REGION=$(\
dialog --title "Zone Choice"\
 --menu "choose your region : "  20 70 10 \
 $region 3>&1 1>&2 2>&3 3>&- )


echo ${TABZONE[$ZONE]}
echo ${TABREGION[$REGION]}

ln -sf /usr/share/zoneinfo/${TABZONE[$ZONE]}${TABREGION[$REGION]} /etc/localtime
hwclock --systohc
locale-gen

LANG=$(\
dialog --title "language Choice"\
 --menu "choose your language system : "  20 70 10 \
 1 FR 2 EN 3>&1 1>&2 2>&3 3>&- )

if [ $LANG -eq 1 ];then
  echo "LANG=fr_FR.UTF-8" > /etc/locale.conf
else
  echo "LANG=en_US.UTF-8" > /etc/locale.conf
fi

KEYBOARD=$(\
dialog --title "layout Choice"\
 --menu "choose your keyboard layout: "  20 70 10 \
 1 FR 2 EN 3>&1 1>&2 2>&3 3>&- )

 if [ $LANG -eq 1 ];then
  echo "KEYMAP=fr" > /etc/vconsole.conf
else
  echo "KEYMAP=us" > /etc/vconsole.conf
fi


MachineName=$(dialog --title "Machine Name" --inputbox "Enter your machine name:" --stdout 8 40)
echo $MachineName > /etc/hostname
echo "127.0.1.1 $MachineName.localdomain $MachineName" >> /etc/hosts

CPU=$(\
dialog --title "Microcode Choice"\
 --menu "choose your CPU manufacturer: "  20 70 10 \
 1 AMD 2 Intel 3>&1 1>&2 2>&3 3>&- )

if [ $CPU -eq 1 ];then
  yes | pacman -S amd-ucode
else
  yes | pacman -S intel-ucode
fi

mkinitcpio -p linux

passwd=""
passwdcheck="-1"

while [ "$passwd" != "$passwdcheck" ]
    do
    if [ $passwdcheck != "-1" ];then
      dialog --title "PASSWORD" --msgbox  ' Passwords are not the same. Please re enter your password ' 10 30
    fi
    echo "in while"
    passwd=$(dialog --title "Password" \
    --clear \
    --insecure \
    --passwordbox "Enter your password" 10 30 \
    --stdout )
   
    passwdcheck=$(dialog --title "Password" \
    --clear \
    --insecure \
    --passwordbox "Re Enter your password" 10 30 \
    --stdout )
done

passwd=""
passwdcheck="Affec"
echo $passwdcheck
rootmdp="root:"
echo $passwd
echo $rootmdp$passwd
########################### BUG ###############################
##                         root::                            ##
$rootmdp$passwd | chpasswd
exit 

yes | pacman -S grub efibootmgr
########################### BUG ###############################
grub-install --target=x86_64-efi --efi-directory=/boot
grub-mkconfig -o /boot/grub/grub.cfg