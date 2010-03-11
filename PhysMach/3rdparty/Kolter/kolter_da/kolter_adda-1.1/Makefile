# Makefile for kolter AD/DA card driver
#

ifneq ($(KERNELRELEASE),)
# called via Kernel Build System
obj-m := kolter_adda.o

else
# Normal invokation

CC	      = gcc
MAKE          = make
CFLAGS	      = -O2 -I/usr/src/linux/include
MAJOR	      = 241
KERNELVERSION = `uname -r`
MODULE_ROOT   = /lib/modules/$(KERNELVERSION)
KDIR          = $(MODULE_ROOT)/build
TESTPROG      = test_adda
TMPFILES      = .tmp_versions *.mod.c .*.cmd *.o

# find out kernel version
ifneq ($(shell uname -r |grep ^2\.[2-5]\.),)
  # kernel 2.2.x ... 2.5.x
  MODNAME   = kolter_adda.o
  BUILD     = $(MODNAME)
  MODULEDIR = $(MODULE_ROOT)/misc/
else
  MODNAME   = kolter_adda.ko
  BUILD     = kbuild
  MODULEDIR = $(MODULE_ROOT)/kernel/misc/
endif

.PHONY: default module kbuild install devices clean

# default rule
default: module $(TESTPROG)

# now the regular rules
module: $(BUILD)

kbuild: kolter_adda.c
	$(MAKE) -C $(KDIR) SUBDIRS=$(shell pwd) modules

$(MODNAME): kolter_adda.c
	$(CC) $(CFLAGS) -D__KERNEL__ -DMODULE -o $@ -c $<

$(TESTPROG): test_adda.c
	$(CC) $(CFLAGS) -o test_adda test_adda.c

devices:
	rm -f /dev/kolter_adda.*
	mknod /dev/kolter_adda.0 c $(MAJOR) 0
	mknod /dev/kolter_adda.1 c $(MAJOR) 1
	mknod /dev/kolter_adda.2 c $(MAJOR) 2
	mknod /dev/kolter_adda.3 c $(MAJOR) 3
	mknod /dev/kolter_adda.4 c $(MAJOR) 4
	mknod /dev/kolter_adda.5 c $(MAJOR) 5
	mknod /dev/kolter_adda.6 c $(MAJOR) 6
	mknod /dev/kolter_adda.7 c $(MAJOR) 7
	chmod a+rw /dev/kolter_adda.*

install: module
	install -d $(MODULEDIR)
	install -m u=rw,g=r,o=r $(MODNAME) $(MODULEDIR)

clean:
	rm -fR *~ $(MODNAME) $(TESTPROG) $(TMPFILES)

endif # ifneq($(KERNELRELEASE),)
