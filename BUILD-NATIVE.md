# Building the Wind River Linux Master Image

## Prerequisites
All prerequisites can be found [here](file:///home/wruser/openamp/end2end/github/repos/wr-vxworks7-openamp-demo-for-zcu102/README.md).

## Downloading, Configuring, and Building the Wind River Linux LTS 18 Sources  
1. Create a directory to build the **Wind River Linux** master project and enter the directory.   
```
mkdir -p lts18-vx7-demo
cd lts18-vx7-demo
```
2. Clone the **Wind River Linux** installer. (You will have to enter your OLS credentials).
```
git clone --branch WRLINUX_10_18_LTS https://windshare.windriver.com/remote.php/gitsmart/WRLinux-lts-18-Core/wrlinux-x
```
3. Run the **setup.sh** script for the **Xilinx Zynqmp** BSP and **standard** distro.  (You will have to accept the EULA and enter your OLS credentials).
```
./wrlinux-x/setup.sh --machines xilinx-zynqmp  --distros wrlinux
```
This step will take some time.

4. Checkout the RCPL6 branch.
```
cd ./wrlinux-x
git checkout WRLINUX_10_18_LTS_RCPL0006
cd ..
```
5. Clone this layer to the **./layers** directory.
```
cd layers
git clone https://github.com/Wind-River/wr-vxworks7-openamp-demo-for-zcu102.git
cd -
```
6. Source the tools script.

```
. ./environment-setup-x86_64-wrlinuxsdk-linux

```
7. Source the project setup script.

```
. ./oe-init-build-env

```
This changes to the **build** directory.  

8. Open the file **./conf/bblayers.conf**  in an editor.
9. Add the **wr-vxworks7-openamp-demo-for-zcu102** layer. 

Note that you will have to add the absolute path that may differ from this example.

```
BBLAYERS ?= " \
	/home/wruser/LTS18/projects/lts18-vx7-demo/layers/wrlinux \
        /home/wruser/LTS18/projects/lts18-vx7-demo/layers/wrlinux/wrlinux-distro \
        /home/wruser/LTS18/projects/lts18-vx7-demo/layers/xilinx-zynqmp \
        /home/wruser/LTS18/projects/lts18-vx7-demo/layers/oe-core/meta \
        /home/wruser/LTS18/projects/lts18-vx7-demo/layers/wr-template \
        /home/wruser/LTS18/projects/lts18-vx7-demo/layers/wr-vxworks7-openamp-demo-for-zcu102 \
        /home/wruser/LTS18/projects/lts18-vx7-demo/layers/meta-openembedded/meta-filesystems \

```

10. Save the file.
11. Open **./conf/local.conf** in an editor.
12. Enable network access for recipes.

```
BB_NO_NETWORK ?= '0'          

```
13. Add **wr-vxworks7-openamp-demo-for-zcu102** to **DISTRO_FEATURES_append**.

```
DISTRO_FEATURES_append = " systemd wr-vxworks7-openamp-demo-for-zcu102 "

```
14. Add the following to the end of the file.

```
PNWHITELIST_wr-vxworks7-openamp-demo-for-zcu102-layer += " rpmsg-echo-test "
IMAGE_INSTALL_append = " rpmsg-echo-test "

IMAGE_INSTALL += " \
packagegroup-core-boot \
${CORE_IMAGE_EXTRA_INSTALL} \
kernel-module-uio-pdrv-genirq \
kernel-module-remoteproc \
kernel-module-virtio \
kernel-module-virtio-ring \
kernel-module-virtio-rpmsg-bus \
rpmsg-echo-test \
"
```
15. Save the file.

16. Build the distro.

```
bitbake wrlinux-image-glibc-std

```
This step will produce the needed artifacts for the demo including:

File |	Description |Destination
:---: |:---:|:---:
./build/tmp-glibc/deploy/images/xilinx-zynqmp/Image-xilinx-zynqmp.bin |	The native Wind River Linux kernel image. |Copied as lts18_a53.bin to the FAT 32 filesystem  (uSD partition 1)
./build/tmp-glibc/deploy/images/xilinx-zynqmp/wrlinux-image-glibc-std-xilinx-zynqmp.tar.bz2 |The native Wind River Linux root filesystem. |	Extracted to the ext4 filestystem (uSD partition 3).
./build/tmp-glibc/deploy/images/xilinx-zynqmp/zynqmp-zcu102-rev1.0.dtb | The native Wind River Linux device tree blob. | Copied to the FAT32 filesystem (uSD partition 1).

 
The kernel image will be renamed to **lts18_a53.bin** and will be booted using **run lx_vx** in the **U-Boot** Shell.

