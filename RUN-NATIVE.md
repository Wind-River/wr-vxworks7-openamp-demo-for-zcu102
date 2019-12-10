# Running the Wind River Linux Master and VxWorks OpenAMP Remote Demo

## Prerequisites

### Tested Board
This example was validated on a **Xilinx Zcu102** populated with 4G RAM. A USB to microUSB cable with a **Silicon Labs CP2108 Quad USB to UART Birdge Controller** is attached between the host computer and the target computer.

### Tested Flash Drive
This example was validated with an 8Gig uSD card with 3 partitions formated as follows:
* partition 1 1-Gig FAT32  
* partition 2 3.5-Gig ext4 (not used in this example)
* partition 3 3.5-Gig ext4 

### Tested BOOT.BIN file
The **BOOT.BIN** file was obtained from the stock [**2018.1**](https://xilinx-wiki.atlassian.net/wiki/spaces/A/pages/18841902/2018.1+u-boot+release+notes#id-2018.1u-bootreleasenotes-Features) version of [**U-Boot**](https://www.xilinx.com/member/forms/download/xef.html?filename=2018.1-zcu102-release.tar.xz).

###  VxWorks OpenAMP Remote ELF Image
The **vxWorks** ELF image created according to the instructions in [VxWorks OpenAMP Layer for Zcu102](https://github.com/Wind-River/vxworks7-openamp-layer-for-zcu102) procedure must be built.

### Wind River Linux Kernel and Root File System
The following images created by [this](https://github.com/Wind-River/wr-vxworks7-openamp-demo-for-zcu102/BUILD-NATIVE.md) procedure must be present.
* ./build/tmp-glibc/deploy/images/xilinx-zynqmp/**Image-xilinx-zynqmp.bin**
* ./build/tmp-glibc/deploy/images/xilinx-zynqmp/**zynqmp-zcu102-rev1.0.dtb**
* ./build/tmp-glibc/deploy/images/xilinx-zynqmp/**wrlinux-image-glibc-std-xilinx-zynqmp.tar.bz2**

## Preparing you target
### Image file locations

This example assumes that
* **BOOT.BIN** was copied to **/tmp**.
* the **Wind River Linux** master project is located in the following directory.
```
wruser@Mothra:~/lts18-vx7-demos
```
* the **VxWorks OpenAMP** remote ELF file is located in the following directory.
```
wruser@Mothra:~/lts18-vx7-demo$ ls ~/WindRiver-SR0620/vx_openamp/rpu-kern-openamp/default/vxWorks 
/home/wruser/WindRiver-SR0620/vx_openamp/rpu-kern-openamp/default/vxWorks
```
### Mount points of relevant partitions on uSD
This example uses the following mount points for the uSD partitions.  
* Partition 1: /media/wruser/EA08-13E2 
* Partition 3: /media/wruser/2ea59d44-bd47-483a-ae2f-0059142bea2d

1. Copy the **BOOT.BIN**, the **Wind River Linux** kernel binary copied as **lts18_a53.bin**, and the DTB to the first partition of the uSD card.  
 
Ensure that the destination name of the **Wind River Linux** kernel image is **lts18_a53.bin.**
```
  cp  /tmp/BOOT.BIN /media/wruser/EA08-13E2/
  cp ~/lts18-vx7-demo/build/tmp-glibc/deploy/images/xilinx-zynqmp/Image-xilinx-zynqmp.bin /media/wruser/EA08-13E2/lts18_a53.bin
  cp ~/lts18-vx7-demo/build/tmp-glibc/deploy/images/xilinx-zynqmp/zynqmp-zcu102-rev1.0.dtb /media/wruser/EA08-13E2/
```

2. Extract the the root file system to partition 3 of the uSD card.
```
sudo tar xf ~/lts18-vx7-demo/build/tmp-glibc/deploy/images/xilinx-zynqmp/wrlinux-image-glibc-std-xilinx-zynqmp.tar.bz2 -C /media/wruser/2ea59d44-bd47-483a-ae2f-0059142bea2d/
```
3. Copy the remote VxWorks ELF image as **vxWorks_r5** to the **/lib/firmware** directory of partition 3.
```
sudo cp /home/wruser/WindRiver-SR0620/vx_openamp/rpu-kern-openamp/default/vxWorks /media/wruser/2ea59d44-bd47-483a-ae2f-0059142bea2d/lib/firmware/vxWorks_r5
```
4. Unmount the uSD card.
5. Powerdown the target, instert the boot medium, and power it back on.
6. From the termnial, hit any key to enter the **ZynqMP>** prompt.

## Configuring **U-boot** Enviroment Variable
At the **ZynqMP>** prompt, enter the following commands to create the variable to boot the **Wind River Linux** master image.
```
setenv  lx_vx 'fatload mmc 0:1 0x10000000 Its18_a53.bin; fatload mmc 0:1 0x11800000 zynqmp-zcu102-rev1.0.dtb; booti 0x10000000 - 0x11800000'
setenv bootargs 'console=ttyPS0,115200 earlyprintk raid=noautodetect root=/dev/mmcblk0p3 rw rootwait'
saveenv
``` 

## Booting Wind River Linux on the APUs and Running the Example

1. Open terminal sessions for the first two serial ports of the QUAD UART attached to the Zynqmp board

The first terminal will show the u-Boot output and will be used by the LTS 18 Master.  The second terminal will show the output of the VxWorks remote.
2. Turn the Zynqmp on and hit any key to stop the U-Boot bootstrap.
```
            U-Boot 2018.01 (Dec 06 2018 - 10:00:41 +0000) Xilinx ZynqMP ZCU102 rev1.0

            I2C: ready
            DRAM: 4 GiB
            EL Level: EL2
            Chip ID: zu9eg
            MMC: mmc@ff170000: 0 (SD)
            SF: Detected n25q512a with page size 512 Bytes, erase size 128 KiB, total 128 MiB
            In: serial@ff000000
            Out: serial@ff000000
            Err: serial@ff000000
            Model: ZynqMP ZCU102 Rev1.0
            Board: Xilinx ZynqMP
            Net: ZYNQ GEM: ff0e0000, phyaddr c, interface rgmii-id
            Warning: ethernet@ff0e0000 MAC addresses don't match:
            Address in ROM is 01:02:03:04:05:06
            Address in environment is aa:bb:cc:dd:ee:ff
            eth0: ethernet@ff0e0000
            Hit any key to stop autoboot: 0 
            ZynqMP>
```
3. At the ZynqMP> prompt enter **run lx_vx**.
 
Wind River Linux will boot.

4. At the login prompt enter the password, **root**.
```
xilinx-zynqmp login: root
```
5. Ensure that the **VxWorks OpenAMP** remote image, **vxWorks_r5**, is in the **/lib/firmware** directory.
```
root@xilinx-zynqmp:~# ls /lib/firmware/
vxWorks_r5
```
6. Load the and start the **VxWorks OpenAMP** remote with **Remoteproc**.
```
root@xilinx-zynqmp:~# echo vxWorks_r5 > /sys/class/remoteproc/remoteproc0/firmware
root@xilinx-zynqmp:~# echo start > /sys/class/remoteproc/remoteproc0/state

```
The image will start and an **RPMsg** channel will be established.
```
remoteproc remoteproc0: powering up ff9a0100.zynqmp_r5_rproc
remoteproc remoteproc0: Booting fw image vxWorks_r5, size 3151464
zynqmp_r5_remoteproc ff9a0100.zynqmp_r5_rproc: RPU boot from TCM.
remoteproc remoteproc0: registered virtio0 (type 7)
remoteproc remoteproc0: remote processor ff9a0100.zynqmp_r5_rproc is now up
virtio_rpmsg_bus virtio0: rpmsg host is online
root@xilinx-zynqmp:~# virtio_rpmsg_bus virtio0: creating channel rpmsg-openamp-demo-channel addr 0x1
```
7. Switch to the other terminal.

The banner for the **vxWorks OpenAMP** remote image is displayed and the creation of channel, **rpmsg-openamp-demo-channel** is confirmed.
```
Adding 8073 symbols for standalone.
-> remote-[tOpenAMP]rpmsg_test_remote(110): remoteproc_resource_init OK, return 0
```
8. Switch back to the first terminal and run the application.
```
root@xilinx-zynqmp:~# /usr/bin/ssp
```
This command will initiate a test where the **Wind River Linux** master will send the string **"1234567890"** to the **VxWorks OpenAMP** remote.  When either ends receives a message to the endpoint in question, it wilL.

* display the received string
* remote the last character
* send the new string back to its peer
* Stop the transmissiong when the string is only on character.

-----"1234567890------------------------->

<-------------------------"123456789"-----

-----"12345678"--------------------------->

<----------------------------"1234567"-----

-----"123456"------------------------------>

<--------------------------------"12345-----

-----"1234"--------------------------------->

<---------------------------------"123"----->

-----"12"------------------------------------->

<--------------------------------------"1"-----
 

7. Observe the output on the first terminal
```
root@xilinx-zynqmp:~# /usr/bin/ssp

Master>probe rpmsg_char

Open rpmsg dev virtio0.rpmsg-openamp-demo-channel.-1.1! 
Opening file rpmsg_ctrl0.
svc_name: rpmsg-openamp-demo-channel
Msg:1234567,len:8
Msg:12345,len:6
Msg:123,len:4
Msg:1,len:2   
```
The output indicates that messages with the following strings were received from the remote: "123456789", "1234567", "12345", "123", "1".

8. Observe the output on the second terminal.
```
remote-[tOpenAMP]rpmsg_channel_created(108): Channel rpmsg-openamp-demo-channel @0x78395530 is created
remote-[tOpenAMP]rpmsg_echo_cb(65): Msg:1234567890,len:11,src:0
remote-[tOpenAMP]rpmsg_echo_cb(65): Msg:12345678,len:9,src:0
remote-[tOpenAMP]rpmsg_echo_cb(65): Msg:123456,len:7,src:0
remote-[tOpenAMP]rpmsg_echo_cb(65): Msg:1234,len:5,src:0
remote-[tOpenAMP]rpmsg_echo_cb(65): Msg:12,len:3,src:0
```
The output indicates that messages with the following strings were received from the master: "1234567890", "12345678", "123456", "1234", "12"
