FILESEXTRAPATHS_prepend := "${THISDIR}:"
SRC_URI_append = " file://openamp-kmeta;type=kmeta;name=openamp-kmeta;destsuffix=openamp-kmeta"

FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI += " \
		file://0001-add-device-tree-r50-remoteproc-definitions.patch \
		file://0002-disable-device-tree-uart1-required-by-vxworks.patch \
		file://0003-enable-device-tree-ttc0.patch \
		file://0004-add-r50-boot-trampoline-code-to-r50-remoteproc.patch \
		file://0005-change-number-of-vring-buffers-and-dont-kick-rxq.patch \
           "

KERNEL_FEATURES_append = "${@bb.utils.contains('DISTRO_FEATURES', 'openamp', ' cfg/openamp.scc', '', d)}"

