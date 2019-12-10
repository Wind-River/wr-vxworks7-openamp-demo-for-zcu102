SUMMARY = "RPMsg examples: echo test demo"

LICENSE = "BSD"
LIC_FILES_CHKSUM = "file://LICENSE;md5=5dc4cff061debeccaa5ced079cf43c31"

SRC_URI = "\
	file://LICENSE \
	file://Makefile \
	file://ssp.c \
	"

S = "${WORKDIR}"

PROVIDES = "rpmsg-echo-test"

RRECOMMENDS_${PN} = "kernel-module-rpmsg-char"

FILES_${PN} = "\
	/usr/bin/ssp \
"

do_install () {
	install -d ${D}/usr/bin
	install -m 0755 ssp ${D}/usr/bin/ssp
}
