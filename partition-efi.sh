
#(echo o; echo n; echo p; echo 1; echo ""; echo +512M; echo n; echo p; echo 2; echo ""; echo ""; echo w; echo q) | fdisk /dev/$(echo $Output_Device) 

(#-----boot----#
echo g
echo n
echo ""
echo ""
echo +512M
echo t
echo 1 #efi label

#----swap-----#
echo n
echo ""
echo ""
echo $swapsize
echo t
echo ""
echo 19 #swap label

#----root----#

echo n
echo ""
echo ""
echo $rootsize
echo t
echo ""
echo 24 #linux x86_64 label 

#----home----#

echo n
echo ""
echo ""
echo $homesize
echo t
echo ""
echo 24 #linux x86_64 label

echo w ) | fdisk /dev/sda