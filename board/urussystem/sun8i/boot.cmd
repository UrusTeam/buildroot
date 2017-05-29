setenv bootargs console=tty0 root=/dev/mmcblk0p2 rootwait
fatload mmc 0:1 $kernel_addr_r zImage
fatload mmc 0:1 $fdt_addr_r sun8i-a23-polaroid-mid2407pxe03.dtb
bootz $kernel_addr_r - $fdt_addr_r
