VxWorks® 7 OpenAMP Demo for the Xilinx Zynq Ultrascale+ MPSoc Wind River Linux Layer
===
---

# Overview
This layer is part of the [OpenAMP for VxWorks Remote Compute](https://github.com/Wind-River/openamp-for-vxworks-remote-compute) project.

Use this layer for creating master images for the following **OpenAMP for VxWorks Remote Compute** demos:
1. **Wind River Linux** master and **VxWorks OpenAMP** remote
*  **VxWorks OpenAMP** remote that resides in **/lib/firmware** of the root file system of **WindRiver Linux** and boots on the **ARM® Cortex®-R5** processor only
2. **Wind River Linux Helix Virtualization Platform** guest master and **VxWorks OpenAMP** remote
*  **VxWorks OpenAMP** remote that resides in **/lib/firmware** of the root file system of **WindRiver Linux Helix Virtualization Platform** guest and boots on the **ARM® Cortex®-R5** processor only

# Project License
The source code for this project is provided under the BSD-3-Clause license.
Text for the open-amp and libmetal applicable license notices can be found in
the LICENSE_NOTICES.txt file in the project top level directory. Different
files may be under different licenses. Each source file should include a
license notice that designates the licensing terms for the respective file.

# Prerequisite(s)
## Wind River Linux Master and VxWorks OpenAMP Remote Demo
* **VxWorks OpenAMP** remote ELF image.  See [VxWorks 7 openAMP Layer for Zcu102](https://github.com/Wind-River/vxworks7-openamp-layer-for-zcu102).
* Network access and a **Windshare** account.
* [**Wind River Linux LTS 18**](https://www.windriver.com/products/linux/) 

## Wind River Linux Helix Virtualization Platform Guest Master and VxWorks OpenAMP Remote Demo
* **VxWorks OpenAMP** remote ELF image.  See [VxWorks 7 openAMP Layer for Zcu102](https://github.com/Wind-River/vxworks7-openamp-layer-for-zcu102).
* Network access and a **Windshare** account.
* [**Wind River Linux LTS 18**](https://www.windriver.com/products/linux/) 
* [**Wind River Helix Virtualization Platform for ARM, SR0620**](https://www.windriver.com/products/helix-platform/)
* **wr-vxvirt-arm64** layer (included with **Wind River Helix Virtualization Platform**)

# Tested Development Environment

## Host Operating System
Both the **VxWorks OpenAMP** master image and the **VxWorks OpenAMP** remote images were created on an Ubuntu 18.04 host.
```
wruser@Mothra:~$ uname -a 
Linux Mothra 5.0.0-32-generic #34~18.04.2-Ubuntu SMP Thu Oct 10 10:36:02 UTC 2019 x86_64 x86_64 x86_64 GNU/Linux
```
## Supported Target
This layer has been tested and is supported with the **Xilinx Zynq UltraScale+ MPSoC ZCU102** only using the **xilinx-zynqmp** BSP. 

## Number of Peers
Only one **Wind River Linux** master and one **VxWorks OpenAMP** remote is supported.
 
## Limits on RPU
**Remoteproc** supports loading and booting **VxWorks** on the first R5 core in split mode.  The second R5 is not used.

## ssp Application with RPMsg Char Driver
Only one application initiated from the **Wind River Linux** master is supported.  This application is compatible with the **ssp** application implemented in the [VxWorks 7 openAMP Layer for Zcu102](https://github.com/Wind-River/vxworks7-openamp-layer-for-zcu102).  The application uses the **RPMsg** Char driver functionality of Linux and supports communications between the channel endpoints only  (i.e. no dynamic EPTs).  The **VxWorks OpenAMP** remote Image must be compiled with **INCLUDE_OPENAMP_SAMPLE_REMOTE_LINUX_CHAR**.

## Workaround for Channel Registration Acknowledgement
After the the **VxWorks OpenAMP** remote umage is started with **Remoteproc**, **VxWorks** advertises the channel to **Linux** and **Linux** in turn announces it.  However, at no point does **Linux** acknowledge the announcement to the **VxWorks OpenAMP** remote.  **VxWorks** will call the channel callback after it receives the first message following its channel announcement, after which it will call the receive callback for successive messages.  As a workaround to this issue, the **ssp** application sends a bogus message to the remote to put the remote in the correct state before it sends the message used to kickstart the application.

## Tested/Implemented
The following has not been tested/implemented with this release.  
Teardown of **RPMsg** connections.

# Creating and Running the Wind River Linux Master and VxWorks OpenAMP Remote Demo
## Creating a VxWorks OpenAMP Remote Image
This image is booted onto the RPU by the **Wind River Linux** master. Instructions can be found [here](https://github.com/Wind-River/vxworks7-openamp-layer-for-zcu102/blob/master/BUILD-REMOTE.md)

## Creating a Wind River Linux master
This image is booted onto the APU using **U-Boot** and contains the **VxWorks OpenAMP** remote ELF image.
Instructions can be found [here](https://github.com/Wind-River/wr-vxworks7-openamp-demo-for-xilinx-zcu102/blob/master/BUILD-NATIVE.md).

## Running the Wind River Linux Master and VxWorks OpenAMP Remote Demo
Instructions can be found [here](https://github.com/Wind-River/wr-vxworks7-openamp-demo-for-xilinx-zcu102/blob/master/RUN-NATIVE.md).

# Creating and Running the Wind River Linux Helix Virtualization Platform Master and VxWorks OpenAMP Remote Demo
## Creating a VxWorks OpenAMP Remote Image
This image is booted onto the RPU by the **Wind River Linux Helix Virtualization Platform** guest master. Instructions can be found [here](https://github.com/Wind-River/vxworks7-openamp-layer-for-zcu102/blob/master/BUILD-REMOTE.md)

## Creating a Wind River Linux Helix Virtualization Platform guest master
This image is booted onto the APU using **U-Boot** and contains the **VxWorks OpenAMP** ELF image.
Instructions can be found [here](https://github.com/Wind-River/wr-vxworks7-openamp-demo-for-xilinx-zcu102/blob/master/BUILD-GUEST.md).

## Creating a Wind River Helix Virtualization Platform Image
This image is booted on the APU using a ccustom **U-Boota** and contains the **VxWorks RootOS**.  The **Helix** hypervisor loads the **VxWorks RootOS** and the **Wind River Linux OpenAMP** guest master.
Instructions can be found [here](https://github.com/Wind-River/wr-vxworks7-openamp-demo-for-xilinx-zcu102//blob/master/BUILD-HELIX.md).

## Running the Wind River Linux Helix Virtualization Platform Guest Master and VxWorks OpenAMP Remote Demo
Instructions can be found [here](https://github.com/Wind-River/wr-vxworks7-openamp-demo-for-xilinx-zcu102/blob/master/RUN-GUEST.md).  
# Legal Notices

All product names, logos, and brands are property of their respective owners. All company,
product and service names used in this software are for identification purposes only. 
Wind River and VxWorks are registered trademarks of Wind River Systems, Inc.  Xilinx,
UltraScale,  Zynq, are trademarks of Xilinx in the United States and other countries.
Arm and Cortex are registered trademarks of Arm Limited (or its subsidiaries) in the US 
and/or elsewhere.

Disclaimer of Warranty / No Support: Wind River does not provide support 
and maintenance services for this software, under Wind River's standard 
Software Support and Maintenance Agreement or otherwise. Unless required 
by applicable law, Wind River provides the software (and each contributor 
provides its contribution) on an "AS IS" BASIS, WITHOUT WARRANTIES OF ANY 
KIND, either express or implied, including, without limitation, any warranties 
of TITLE, NONINFRINGEMENT, MERCHANTABILITY, or FITNESS FOR A PARTICULAR 
PURPOSE. You are solely responsible for determining the appropriateness of 
using or redistributing the software and assume any risks associated with 
your exercise of permissions under the license.
