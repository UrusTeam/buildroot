setenv bootargs cma=256M console=ttyS0,115200 hdmi.audio=EDID:0 disp.screen0_output_mode=1280x720p60 consoleblank=0 root=/dev/mmcblk0p2 rootwait

fatload mmc 0 $kernel_addr_r zImage
fatload mmc 0 $fdt_addr_r sun8i-h3-orangepi-lite.dtb

bootz $kernel_addr_r - $fdt_addr_r
