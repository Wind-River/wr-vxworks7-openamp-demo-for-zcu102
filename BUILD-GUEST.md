# Building the Wind River Linux Helix Virtualization Platform Guest Master Image

**The procedure references and extends the [Building the Wind River Linux Master Image](https://github.com/Wind-River/wr-vxworks7-openamp-demo-for-zcu102/blob/master/BUILD-NATIVE.md) procedure.**

It is helpful to open the afformented web page and this web page at the same time.

## Prerequisites
All prerequisites can be found [here](https://github.com/Wind-River/wr-vxworks7-openamp-demo-for-zcu102).

## Downloading, Configuring, and Building the Wind River Linux LTS 18 Sources  

1. Create a directory to build the **Wind River Linux Helix Virtualization Platform** guest master project and enter the directory.   

```
mkdir -p helix-lts18-vx7-demo
cd helix-lts18-vx7-demo
```
2 Perform steps 2 to 5 in [Building the Wind River Linux Master Image](https://github.com/Wind-River/wr-vxworks7-openamp-demo-for-zcu102/blob/master/BUILD-NATIVE.md).

At this point you will have a have a project directory with the **wr-vxworks7-openamp-demo-for-zcu102** layer added to the **helix-lts18-vx7-demo/layers** directory. 

The next step assumes that you have access to a **Wind River Helix Virtualization Platform, SR0620** on your host machine and that the evironment variable, **WIND_HOME** is set to the root of your **Wind River Helix Virtualization Platform** installation.
```
wruser@Mothra:~/helix-lts18-vx7-demo$ echo $WIND_HOME
/home/wruser/Helix-SR0620
```

3. Copy the **wr-vxvirt-arm64** layer from the **Wind River Helix Platform** installation with the following command.
```
cp -a $WIND_HOME/helix/guests/wrlinux-lts-18/xilinx-zynqmp/drivers/wr-vxvirt-arm64  ./layers
```
4. Perform steps 6 to 9 in [Building the Wind River Linux Master Image](https://github.com/Wind-River/wr-vxworks7-openamp-demo-for-zcu102/blob/master/BUILD-NATIVE.md).
At this point **bblayers.conf** will be open in an editor.

5. Add the **wr-vxvirt-arm64** layer to **bblayers.conf**.
Note that you will have to add the absolute path that may differ from this example.
```
BBLAYERS ?= " \
/home/wruser/LTS18/projects/helix-lts18-vx7-demo/layers/wrlinux \
/home/wruser/LTS18/projects/helix-lts18-vx7-demo/layers/wrlinux/wrlinux-distro \
/home/wruser/LTS18/projects/helix-lts18-vx7-demo/layers/xilinx-zynqmp \
/home/wruser/LTS18/projects/helix-lts18-vx7-demo/layers/oe-core/meta \
/home/wruser/LTS18/projects/helix-lts18-vx7-demo/layers/wr-template \
/home/wruser/LTS18/projects/helix-lts18-vx7-demo/layers/wr-vxworks7-openamp-demo-for-zcu102 \
/home/wruser/LTS18/projects/helix-lts18-vx7-demo/layers/wr-vxvirt-arm64 \
/home/wruser/LTS18/projects/helix-lts18-vx7-demo/layers/meta-openembedded/meta-filesystems \
...
```

Both **wr-vxworks7-openamp-demo-for-zcu102** and **wr-vxvirt-arm64** layers should be added to to **BBLAYERS**.

6. Save the file.

7. Open the file, **./layers/wr-vxworks7-openamp-demo-for-zcu102/recipes-demos/rpmsg-echo-test/files/ssp.c** in an editor and locate the main **function** line.

```
int main(int argc, char *argv[])
    {
       int ret, i, j;
       err_cnt = 0;
       int opt;

       char *rpmsg_dev="virtio0.rpmsg-openamp-demo-channel.-1.1";
       int ntimes = 1;
    ...

```
8. Change the **rpmsg_dev** variable to use **virtio1** instead of **virtio0** as follows:
```
char *rpmsg_dev="virtio1.rpmsg-openamp-demo-channel.-1.1";
```
9. Save the file.
10. Open the file, **./layers/wr-vxworks7-openamp-demo-for-zcu102/recipes-kernel/linux/linux-yocto_%.bbappend** in an editor.
11. Add the **0006-change-helix-dts-parameters-for-openamp.patch** to the recipe file.
```
FILESEXTRAPATHS_prepend := "${THISDIR}:"
SRC_URI_append = " file://openamp-kmeta;type=kmeta;name=openamp-kmeta;destsuffix=openamp-kmeta"
            
FILESEXTRAPATHS_prepend := "${THISDIR}/files:"
            
SRC_URI += " \
file://0001-add-device-tree-r50-remoteproc-definitions.patch \
file://0002-disable-device-tree-uart1-required-by-vxworks.patch \
file://0003-enable-device-tree-ttc0.patch \
file://0004-add-r50-boot-trampoline-code-to-r50-remoteproc.patch \
file://0005-change-number-of-vring-buffers-and-dont-kick-rxq.patch \
file://0006-change-helix-dts-parameters-for-openamp.patch \
"
KERNEL_FEATURES_append = "${@bb.utils.contains('DISTRO_FEATURES', 'wr-vxworks7-openamp-demo-for-zcu102', ' cfg/openamp.scc', '', d)}"
```

12. Save the file.

13. Perform steps 11 to 14 in [Building the Wind River Linux Master Image](https://github.com/Wind-River/wr-vxworks7-openamp-demo-for-zcu102/blob/master/BUILD-NATIVE.md).
 
14. Add the **vnic** template.
```
WRTEMPLATE ?= "feature/vnic"
```
15. Add **vnic** to **IMAGE_INSTALL_append**.

```
IMAGE_INSTALL_append = " rpmsg-echo-test  vnic" 
```
16. Save the file.
17. Build the distro.
```
bitbake wrlinux-image-glibc-stdc
```
This step will produce the needed artifacts for the demo including:
File | Description | Destination
:---: |:---:|:---:
 ./build/tmp-glibc/deploy/images/xilinx-zynqmp/Image-xilinx-zynqmp.bin | The Wind River Linux Helix Guest OS image. | Stored in romfs of Root OS.
./build/tmp-glibc/deploy/images/xilinx-zynqmp/wrlinux-image-glibc-std-xilinx-zynqmp.tar.bz2 | The Wind River Linux Helix Guest OS root filesystem. | Extracted to the ext4 filestystem (uSD partition 2).
 ./build/tmp-glibc/deploy/images/xilinx-zynqmp/zynqmp-zcu102-hvp.dtb |	The Wind River Linux Helix Guest OS device tree blob. |	Stored in romfs of Root OS.

