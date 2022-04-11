#### shrinkimg.sh

 Shrinks the given **ext4** disk image by reducing the size of the last partition to the specified size 
 Used to reduce the size of a disk image which contains free space

> /!\ this script only works if the selected partition is at the end of the disk otherwise it could brake your partition table /!\


usage: 
```
 usage: ./shrinkimg.sh [path]     [partition_to_shrink]     [size]
 eg:    ./shrinkimg.sh /path/to/img          2    		    10G
```