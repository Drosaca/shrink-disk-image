#!/bin/bash
set -e
if [[ $1 = "-h" ]] || [[ -z $1  ]]
then
	echo " usage: ./shrinkimg.sh [path]     [partition_to_shrink]     [size]"
	echo " eg:    ./shrinkimg.sh /path/to/img          2    		    10G"
	exit 0
fi
imgPath=${1}
partToShrink=${2}
imgName=$(echo $imgPath | grep -Po "(\w|\.)*$")
sudo losetup -fP $imgPath
loopName=$(losetup | grep $imgName | grep -o "/dev/\w*" | grep -o "\w*$" | head -1)
echo created loopdevice $loopName for $imgName
#resize partition
disk=$(echo /dev/${loopName})
device=$(echo /dev/${loopName}p${partToShrink})
size=${3}
partnb=$(echo $device | grep -o "[0-9]*$")
echo Resize partititon $device on $disk to $size
sudo e2fsck -f $device -y
sudo resize2fs $device $size
BlockCount=$(sudo dumpe2fs -h $device | grep "Block count" | grep -i -o '[0-9]*') 
BlockSize=$(sudo dumpe2fs -h $device | grep "Block size" | grep -i -o '[0-9]*') 
PartitionSize=$(expr $BlockCount \* $BlockSize)  
StartByte=$(sudo parted $disk unit b print | grep -wo '[0-9]*B' | tail -3 | head -1 | grep -o "[0-9]*") 
EndByte=$(expr $StartByte + $PartitionSize - 1) 
echo BlockCount: $BlockCount
echo PartitionSize: $PartitionSize
echo BlockSize: $BlockSize
echo StartByte: $StartByte
echo EndByte: $EndByte
echo resizing Partition $partnb...

sudo parted $disk unit b rm $partnb mkpart primary ext4 $StartByte $EndByte
sudo e2fsck -f $device
echo Partition $partnb resized EndByte: $EndByte
truncate --size=$[$EndByte + 1] $imgPath