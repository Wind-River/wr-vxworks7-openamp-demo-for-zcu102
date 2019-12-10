# Running the Wind River Linux Helix Virtualization Guest Master and VxWorks OpenAMP Remote Demo
 
# Prerequisites

### Tested Board
This example was validated on a **Xilinx Zcu102** populated with 16G RAM. A USB to microUSB cable with a **Silicon Labs CP2108 Quad USB to UART Birdge Controller** is attached between the host computer and the target computer.

### Tested Flash Drive
This example was validated with an 8Gig uSD card with 3 partitions formated as follows:
* partition 1 1-Gig FAT32
* partition 2 3.5-Gig ext4 
* partition 3 3.5-Gig ext4 (not used in this example)

### Tested BOOT.BIN file
This demo requires a custom version of **BOOT.BIN** that has modifications to **U-Boot** and the secure monitor as well as 16G RAM support. It is not available for download.  Please contact Wind River. 

### Wind River Helix Binary Image
The **vxWorks.bin** ELF image created by [this](https://github.com/Wind-River/vxworks7-openamp-layer-for-zcu102/BUILD-HELIX.md) procedure must be built.

###  VxWorks OpenAMP remote ELF Image
The **vxWorks** ELF image created according to the instructions in [VxWorks OpenAMP Layer for Zcu102](https://github.com/Wind-River/vxworks7-openamp-layer-for-zcu102) procedure must be built.

### Wind River Linux Kernel and Root File System
The following images created by [this](https://github.com/Wind-River/wr-vxworks7-openamp-demo-for-zcu102/BUILD-NATIVE.md) procedure must be present.
* ./build/tmp-glibc/deploy/images/xilinx-zynqmp/**wrlinux-image-glibc-std-xilinx-zynqmp.tar.bz2**

## Preparing you target
### Image file locations

This example assumes that
* BOOT.BIN was copied to **/tmp**.
* the **Wind River Linux** master project is located in the following directory.
```
wruser@Mothra:~/helix-lts18-vx7-demo
```
* the **VxWorks OpenAMP** remote ELF file is located in the follwing directory.
```
wruser@Mothra:~/helix-lts18-vx7-demo$ ls ~/WindRiver-SR0620/vx_openamp/rpu-kern-openamp/default/vxWorks 
/home/wruser/WindRiver-SR0620/vx_openamp/rpu-kern-openamp/default/vxWorks
```
* the **Wind River Helix** binary is located in the following directory.
```
wruser@Mothra:~/helix-lts18-vx7-demo$ ls ~/Helix-SR0620/hx_openamp/apu-kern-helix/default/vxWorks.bin 
/home/wruser/Helix-SR0620/hx_openamp/apu-kern-helix/default/vxWorks.bin
```
### Mount points of relevant partitions on uSD
This example uses the following mount points for the uSD partitions.
* Partition 1: /media/wruser/EA08-13E2 
* Partition 2: /media/wruser/910b25f6-bed6-49d7-937e-89cfa8eef498

1. Copy the **BOOT.BIN**, and the **Wind River Helix Virtualization Platform** binary as **helix_a53.bin** to the first partition of the uSD card.
```
  cp  /tmp/BOOT.BIN /media/wruser/EA08-13E2/
  cp /home/wruser/Helix-SR0620/hx_openamp/apu-kern-helix/default/vxWorks.bin /media/wruser/EA08-13E2/helix_a53.bin
```

2. Extract the root file system to partition 2 of the uSD card.
```
sudo tar xf ~/helix-lts18-vx7-demo/build/tmp-glibc/deploy/images/xilinx-zynqmp/wrlinux-image-glibc-std-xilinx-zynqmp.tar.bz2 -C /media/wruser/910b25f6-bed6-49d7-937e-89cfa8eef498/
```
3. Copy the remote VxWorks ELF image as **vxWorks_r5** to the **/lib/firmware** directory of partition 2.
```
sudo cp /home/wruser/WindRiver-SR0620/vx_openamp/rpu-kern-openamp/default/vxWorks /media/wruser/910b25f6-bed6-49d7-937e-89cfa8eef498/lib/firmware/vxWorks_r5
```
4. Unmount the uSD card.
5. Powerdown the target, insert the boot medium, and power it back on.
6. From the terminal, hit any key to enter the **ZynqMP>** prompt.

## Configuring U-boot Enviroment Variable
At the **ZynqMP>** prompt, enter the following commands to create the variable to boot the **Wind River Helix Virtualization Platform** image.
```
setenv hx_lx_vx 'fatload mmc 0:1 0x100000 helix_a53.bin; go 100000'
saveenv
```
## Booting Helix and Running the Example
1. Open terminal sessions for the first two serial ports of the QUAD UART attached to the Zynqmp board

The first terminal shows the **U-Boot** output and will be used by **Helix**. The second terminal will show the output of the **VxWorks OpenAMP** remote.

2. Turn the target on and hit any key to stop the **U-Boot** bootstrap.
```
            Release 2018.3 Apr 11 2019 - 21:05:01
            NOTICE: ATF running on XCZU9EG/silicon v4/RTL5.1 at 0xfffea000
            NOTICE: BL31: Secure code at 0x0
            NOTICE: BL31: Non secure code at 0x8000000
            NOTICE: BL31: v1.5(release):
            NOTICE: BL31: Built : 15:59:34, Apr 3 2019
            PMUFW: v1.1


            U-Boot 2018.01-dirty (Apr 03 2019 - 15:00:40 -0400) Xilinx ZynqMP ZCU102 rev1.0

            I2C: ready
            DRAM: 4 GiB
            EL Level: EL2
            Chip ID: zu9eg
            MMC: sdhci@ff170000: 0 (SD)
            reading uboot.env
            In: serial@ff000000
            Out: serial@ff000000
            Err: serial@ff000000
            Net: ZYNQ GEM: ff0e0000, phyaddr c, interface rgmii-id

            Warning: ethernet@ff0e0000 (eth0) using random MAC address - 1a:6e:14:5d:66:4b
            eth0: ethernet@ff0e0000
            Hit any key to stop autoboot: 0 
            ZynqMP>
```
Note that this custom version of **U-Boot** comes up in EL2 mode which is required for **Helix**.   Also note that the board has 16G of RAM but the DRAM value shows 4G.   This ouput is incorrect but expected.

3. At the **ZynqMP>** prompt enter **run hx_lx_vx**.
**Helix** will boot and launch the **VxWorks RootOS** which brings up the other guests. The **VxWorks** target shell prompt will appear.
``
->
``
4.  Tip into the **Wind River Linux Helix Virtualization Platform** guest master by executing the following command at the **VxWorks** target shell prompt.
```
-> tip "dev=/tyCo/16"

```
5. At the login prompt, login as root.

```
Wind River Linux LTS 18.44 Update 8 xilinx-zynqmp hvc0

xilinx-zynqmp login: root
root@xilinx-zynqmp:~# 
```
6. Perform steps 5 to 8 of the **Booting Wind River Linux on the APUs and Running the Example** section in [Running the Wind River Linux LTS 18 Master, VxWorks Remote Demo](https://github.com/Wind-River/wr-vxworks7-openamp-demo-for-zcu102/RUN-NATIVE.md). 

Note that this example uses virtio1.rpmsg-openamp-demo-channel.-1.1 as the rpmsg_char device.
