# Building the Wind River Helix Virtualization Platform Image

## Prerequisites
All prerequisites can be found [here](https://github.com/Wind-River/wr-vxworks7-openamp-demo-for-zcu102).

## Creating, Configuring and Building Source Build Project for Wind River Helix Virtualization Platform
The following procedure was executed on a Linux host using a **Helix Development Shell**.

1. Start **Workbench** and select a new directory for the workpace.

2. From the top menu, select **Project > Open Development Shell…**.

A **Helix Development shell** (**Helix** tab) will appear under the **Terminal** tab.

3. Click the **Build Console** tab and ensure that the **Parallel Builds** icon has parallel builds enabled.

4. Click on the **Helix** tab to bring the **Helix Development shell** into focus.

Stock **Wind River Helix Virtualization Platform for ARM, SR020** is missing the ability to parse the **hvconfig** **BOOTLINE** for **Linux**.
Steps 5 to  8 remedy this issue.  If this has been fixed in your installation, you may skip to step 9.  

5. Open the following file in an editor: **$WIND_HOME/helix/pkgs_v2/hv/hypervisor-4.1.0.0/vmm/arch/arm/src/v8/wrhvArch.c**
6. Search for the following comment string: **"for ARM64 Linux VM: parent node name and size-cells are different"**.
7. Add the following text in bold after conditional that has the comment string above.
```
  if (info->vcore[0].vmConfig->guestOS == ENUM_LINUX_PRELOADED)
    {
            
       /* for ARM64 Linux VM: parent node name and size-cells are different */

      parentSbName = fdtArchSbTypeAndSizeCellsGet (pGuestFdt,
      &parentSbSizeCells);
    }

    /* get the boot line from the registry */
    kprintf("getting bootLine2\n");
    if (cfgVmStringGet (info->name, HV_VM_BOOTLINE_STR,
       bootLine, sizeof(bootline_t)) == OK)
       {

            /* set the bootLine in the device tree */
            kprintf("setting bootline2 to %s\n", bootLine);
             archFdtGuestBootlineSet (pGuestFdt, bootLine);
       }
```
8. Save the file.

For convenience, the commands executed in the rest of this section rely on environment variables defined for the various project names.  You may change the names of the projects by setting the appropriated variables.

9. Define the name of the source build project for the **Wind River Helix Virtualization Platform** image.
```
export HELIX_VSB=apu-libs-helix
```
10. Define the name of the kernel image project for the **Wind River Helix Virtualization Platform** image.
```
export HELIX_VIP=apu-kern-helix
```
11. Define the name of the **romfs** project for the **Wind River Helix Virtualization Platform** image that will contain the guest images and config script.
```
export HELIX_ROMFS=apu-romfs-helix
```
12. Create the source build project based on the **xlnx_zynqmp** BSP.
```
wrtool prj vsb create -bsp xlnx_zynqmp -S $HELIX_VSB
```
The **apu-libs-helix** project appears in the **Project Explorer**.

13. Enable the virtualization layers.
```
wrtool prj vsb add \
HYPERVISOR \
HYPERVISOR_VMM \
$HELIX_VSB
```
14. Build the project.
```
wrtool prj build $HELIX_VSB
```
Note:  this step will take some time to complete.


## Creating, Configuring and Building Image Project with Romfs for Wind River Helix Virtualization Platform

The image project will contain a romFS with the Hypervisor CLI configuration script and the **Wind River Linux Helix Virtualization Platform** guest master kernel files.

This example assumes the following:
* the workspace directory is the following .
```
wruser@Mothra:~/Helix-SR0620/hx_openamp$ 
```
* the **Wind River Linux Helix Virtualization Platform** guest master was build from a project directory accessible on the host.
```
wruser@Mothra:~/Helix-SR0620/hx_openamp$ ls ~/helix-lts18-vx-demo/
bin      build   default.xml                                layers  oe-init-build-env  scripts
bitbake  config  environment-setup-x86_64-wrlinuxsdk-linux  meta    README             wrlinux-x
``` 
1. Create a directory called **images** in your workspace.
```
wruser@Mothra:~/Helix-SR0620/hx_openamp$ mkdir images
```

2. Create a file called **custom-hvconfig** in the **images** directory.  This will be customized later.
```
wruser@Mothra:~/Helix-SR0620/hx_openamp$ touch images/custom-hvconfig 
```

3. Copy the kernel image and device tree blob into the **images** directory..
```
cp ~/helix-lts18-vx-demo/build/tmp-glibc/deploy/images/xilinx-zynqmp/Image-xilinx-zynqmp.bin ./images
cp ~/helix-lts18-vx-demo/build/tmp-glibc/deploy/images/xilinx-zynqmp/zynqmp-zcu102-hvp.dtb ./images
```

The files in the **images** will be copied by the build system to the romfs when the image is built.

1. Next, create the image project based on the VSB created in the previous section and with **PROFILE_STANDALONE_DEVELOPMENT**.
```
wrtool prj vip create -vsb $HELIX_VSB xlnx_zynqmp llvm $HELIX_VIP
```
The **apu-kern-helix** project appears in the **Project Explorer**.

2. Execute the following commands to configure the image project.
```
wrtool prj vip bundle add $HELIX_VIP \
BUNDLE_HYPERVISOR_ROOTOS \
BUNDLE_STANDALONE_SHELL

wrtool prj vip component add $HELIX_VIP \
INCLUDE_STANDALONE_DTB \
INCLUDE_DEBUG_KPRINTF \
INCLUDE_ROMFS \
INCLUDE_HV_ROOTOS_VNET \
INCLUDE_IPNET_IFCONFIG_2

wrtool prj vip component  remove $HELIX_VIP \
DRV_END_FDT_XLNX_ZYNQ

wrtool prj vip parameter set $HELIX_VIP VIRTIO_SIO_TTY_BUF_SIZE 4096
wrtool prj vip parameter setstring $HELIX_VIP  HYPERVISOR_DEVICE_BLACKLIST "/mainbus@0/fdtBus@0/soc@17c/timer@ff140000"
wrtool prj vip parameter set $HELIX_VIP RAM_HIGH_ADRS 0xffffffff93000000
wrtool prj vip parameter set $HELIX_VIP HYPERVISOR_BOOT_CONFIG_FILE "/romfs/custom-hvconfig"
wrtool prj vip parameter set $HELIX_VIP IFCONFIG_2 "\"ifname vnic0\",\"devname vnic\",\"inet 10.0.0.1/24\",\"gateway 0.0.0.0\""
```

3. Build the project to bring in the needed hypervisor related files.
```
wrtool prj build $HELIX_VIP 
```

4. Execute the following commands to create a romfs sub-project containing the **Wind River Linux Helix Virtualization Platform** guest master and the **custom-hvconfig** script.  
```
wrtool prj romfs create -force $HELIX_ROMFS
wrtool prj romfs add -file ./images/custom-hvconfig $HELIX_ROMFS
wrtool prj romfs add -file ./images/Image-xilinx-zynqmp.bin $HELIX_ROMFS
wrtool prj romfs add -file ./images/zynqmp-zcu102-hvp.dtb $HELIX_ROMFS
wrtool prj subproject add $HELIX_ROMFS $HELIX_VIP
```
The romfs project defined in **$HELIX_ROMSFS** will appear as a subproject of **$HELIX_VIP**.

5. From the top menu select **File > Open File...**.
6. Navigate to the **images** directory in your workspace, and double click on **custom-hvconfig**.  The custom-hvconfig editor tab opens.
7. Add the following to the custom-hvconfig file:
```
\# hvconfig version 0
  
\# config for gos-wrlx
network configure vnet0
interface create vnic0
exit


vm create lts18_master
vm configure lts18_master
attribute set GuestOS to "Linux"
device configure cpu0 core configure core0 attribute set PhysicalCore to 1
device configure ram memory configure region0 attribute set Length to 0x80000000
attribute set FragmentedMemoryEnable to "True"
#device configure ram memory configure region0 attribute set Length to 0x40000000
device configure cpu0 attribute set Cores to 2

\# openAMP devices
device add openamp_shmem_77f00000
device add sdhc_ff160000
device add r5_0_tcm_a_ffe00000
device add r5_0_tcm_b_ffe20000
device add ddr_78000000
device add zynqmp_r5_rproc_0

device add ethernet_ff0e0000
device add i2c_ff020000
device add i2c_ff030000
device add gpio_ff0a0000
device add pcie_fd0e0000
device add qspi_ff0f0000
device add usb_fe200000
device add usb_fe300000
image add /romfs/Image-xilinx-zynqmp.bin
image configure /romfs/Image-xilinx-zynqmp.bin attribute set Type to BIN
image configure /romfs/Image-xilinx-zynqmp.bin attribute set Address to 0x80000
attribute set PayloadStartAddr to 0x80000
attribute set PayloadStartAddr to 0x80000
device add vnic0
device add vconsole0
image add /romfs/zynqmp-zcu102-hvp.dtb
device add sdhc_ff170000
attribute set BootLine to "vbbquiet root=/dev/mmcblk0p2 rootwait console=hvc0 raid=noautodetect vnic=10.0.0.3,255.255.255.0,10.0.0.1"
\################################################################
exit


\# Start the Wind River Linux Helix Virtualization Platform guest master
vm start lts18_master
```
8. Click in the tab and type **Ctrl-s** to save the file.
9. Return to the Project Explorer and expand **xlnx_zynmp_2_0_2_0** under the root OS project.
1o. Double-click **xlnx-zcu102-rev-1.1.dts** to bring up an editor tab.
11. In the **xlnx-zcu102-rev-1.1.dts** tab locate the memory configuration following:
```
 memory
        {
        device_type = "memory";
        
        reg = <0x0 0x00000000 0x0 0x80000000>,
              <0x8 0x00000000 0x0 0x80000000>;           
        };
```
12. Edit the file to leave a 129M gap where the **Wind River Linux Helix Virtualization Platform** master guest will load the **VxWorks OpenAMP** remote and configure virtiIO.
```
 memory
        {
        device_type = "memory";
        
 	reg = <0x0 0x00000000 0x0 0x77f00000>,
              <0x8 0x00000000 0x3 0x80000000>;
        };
```
13. Type **Ctrl-s** to save the configuration.
14. Return to the **Project Explorer** under **xlnx_zynmp_2_0_2_0** and double-click **zynqmp.dsti**.
15. In the **zynqmp.dsti** editor tab, type **Ctrl-f** and type **can1** beside **Find:**.
16. Insert the following under the **can1:** node.
```
can1: xcanps@0xff070000
  {
    compatible = "xlnx,xcanps";
    status = "disabled";
    reg = <0x0 0xff070000 0x0 0x1000>;
    clock-frequency = <20000000>;
    interrupts = <56 0 4>;
    interrupt-parent = <&intc>;
    };
            
       
openamp_shmem: openamp_shmem@77f00000
  {
    reg = <0 0x77f00000 0 0x100000>;
    status = "disabled"; 
  };
                
elf_ddr_0: ddr@78000000 {
  compatible = "mmio-sram";
  reg = <0x0 0x78000000 0x0 0xB00000>;
  status = "disabled";              
};
 
r5_0_tcm_a: r5_0_tcm_a@ffe00000 
  {
    reg = <0x0 0xFFE00000 0x0 0x10000>;
    status = "disabled"; 
  };
             
r5_0_tcm_b: r5_0_tcm_b@ffe20000 
  {
    reg = <0x0 0xFFE20000 0x0 0x10000>;
    status = "disabled"; 
  };
             
test_r50: zynqmp_r5_rproc@0 {
  reg = <0x0 0xff9a0100 0x0 0x100>, <0x0 0xff340000 0x0 0x100>, <0x0 0xff9a0000 0x0 0x100>;
  interrupts = <61 0 4>;
  interrupt-parent = <&intc>;
             
  status = "disabled"; 
} ;
```
17. Next type **Ctrl-s** to save the configuration.
18. Return to the **Project Explorer** and expand **hv_xlnx_zynqmp** under the root OS vip.
19. Double-click **zynqPmLib.c**.
20. In the **zynqPmLib.c** editor tab insert the following code below **\/\* includes \*\/**.
```
/* includes */
#define LINUX_R5_REMOTEPROC_CONTROL
            
#include <wrhv.h>
#include "zynqPmLib.h"
            
#ifdef LINUX_R5_REMOTEPROC_CONTROL
#include <stdbool.h>
#endif

/* defines */

#define ZYNQ_PM_RESULT(regs) regs->x[0]
#define ZYNQ_PM_ARG(regs, idx) regs->x[idx]
            
#ifdef LINUX_R5_REMOTEPROC_CONTROL
enum power_domain {
  pd_r5_0 = 0x7,
  pd_tcm_0_a = 0xf,
  pd_tcm_0_b = 0x10
};
            
bool isR5PowerDomain(int pd) {
   bool r5Domain = false;
             
   switch (pd) {
     case pd_r5_0:
     case pd_tcm_0_a:
     case pd_tcm_0_b:
     r5Domain = true; 
   }
 
   return(r5Domain);
}
            
#endif
```

21. Locate the **zynqPmReqHandler** function and add the following code at the beginning of the **switch** statement.
```
switch(funcId)
  {
 
   #ifdef LINUX_R5_REMOTEPROC_CONTROL
     /* for these requests let the requests happen for the power domains 
      * required for configuring R5 related memory access else just return
      * success.
      */
     case ZYNQ_PM_GET_NODE_STATUS:
     case ZYNQ_PM_FORCE_POWERDOWN: 
     case ZYNQ_PM_REQUEST_WAKEUP: 
     case ZYNQ_PM_REQUEST_NODE: 
     case ZYNQ_PM_RELEASE_NODE: 
     pd = regs->x[1];

     if (! isR5PowerDomain(pd)) {
       ZYNQ_PM_RESULT(regs) = (uint64_t) ZYNQ_PM_RET_SUCCESS;
       break;
     }
   #endif
```
22. in the same function, locate **case ZYNQ_PM_SET_REQUIREMENT:** and make the following modification.
```
   #ifndef LINUX_R5_REMOTEPROC_CONTROL
      case ZYNQ_PM_REQUEST_NODE ... ZYNQ_PM_SET_REQUIREMENT: 
   #else
       case ZYNQ_PM_SET_REQUIREMENT:
   #endif
```
23. Next locate **case ZYNQ_PM_SET_CONFIGURATION ... ZYNQ_PM_SYSTEM_SHUTDOWN:** and make the following modification.
```
   #ifndef LINUX_R5_REMOTEPROC_CONTROL
      case ZYNQ_PM_SET_CONFIGURATION ... ZYNQ_PM_SYSTEM_SHUTDOWN:
   #else
      case ZYNQ_PM_SET_CONFIGURATION:
      case ZYNQ_PM_GET_OPERATING_CHARACTERISTIC ... ZYNQ_PM_SELF_SUSPEND:
      case ZYNQ_PM_ABORT_SUSPEND:
      case ZYNQ_PM_SET_WAKEUP_SOURCE ... ZYNQ_PM_SYSTEM_SHUTDOWN:
   #endif
```
24. Type **Ctrl-s** to save the configuration.

25. Build the project.
```
wrtool prj build $HELIX_VIP -target vxWorks.bin

```
When the build completes the **vxWorks.bin** binary image will reside in **$HELIX_VIP/default/**.
This file will be renamed to **helix_a53.bin** and booted using **run hx_lx_vx** from the **U-Boot** shell.
