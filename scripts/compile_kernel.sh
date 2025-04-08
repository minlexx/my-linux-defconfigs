#!/bin/bash

. /lib/gentoo/functions.sh

# check if .config exists
if [[ ! -e .config ]]; then
	ewarn "can't find .config, will copy from previous kernel (../linux symlink)"
	ebegin "Copy ../linux/.config ./.config"
	cp ../linux/.config ./.config
	eend $?
else
	einfo "Found existing .config"
fi

ebegin "Compiling kernel..."
nice make -j8 oldconfig && nice make -j8
eend $?
ebegin "Compile/install modules..."
nice make modules_install
eend $?
ebegin "Install kernel image..."
nice make install
eend $?

einfo "Installed kernels:"
eselect kernel list

LAST_KERNEL=$(eselect kernel list | tail -n 1 | awk '{ print $2 }')

einfo "Setting latest kernel: ${LAST_KERNEL}"
eselect kernel set ${LAST_KERNEL}
eselect kernel list

ebegin "Rebuilding packages that install kernel modules..."
nice /root/module-rebuild.sh
eend $?

einfo "Contents of /boot:"
ls -l --color /boot
einfo "Contents of /lib/modules:"
ls -l --color /lib/modules
