# Makefile for kolter TTL card driver
#

ifneq ($(KERNELRELEASE),)
# called via Kernel Build System
obj-m := kolter_1616.o

else
# normal invokation

CC	      = gcc
MAKE          = make
CFLAGS	      = -O2 -I/usr/src/linux/include
MAJOR	      = 240
KERNELVERSION = `uname -r`
MODULE_ROOT   = /lib/modules/$(KERNELVERSION)
KDIR          = $(MODULE_ROOT)/build
MODULEDIR     = $(MODULE_ROOT)/misc/
TESTPROG      = test_1616
TMPFILES      = .tmp_versions *.mod.c .*.cmd *.o

# find out kernel version
ifneq ($(shell uname -r |grep ^2\.[2-5]\.),)
  # kernel 2.2.x ... 2.5.x
  MODNAME   = kolter_1616.o
  BUILD     = $(MODNAME)
  MODULEDIR = $(MODULE_ROOT)/misc/
else
  MODNAME   = kolter_1616.ko
  BUILD     = kbuild
  MODULEDIR = $(MODULE_ROOT)/kernel/misc/
endif

.PHONY: default module kbuild install devices clean

# default rule
default: module $(TESTPROG)

# now the regular rules
module: $(BUILD)

kbuild: kolter_1616.c
	$(MAKE) -C $(KDIR) SUBDIRS=$(shell pwd) modules

$(MODNAME): kolter_1616.c kolter_1616.h 
	$(CC) $(CFLAGS) -D__KERNEL__ -DMODULE -o $@ -c $<

$(TESTPROG): test_1616.c kolter_1616.h
	$(CC) $(CFLAGS) -o $@ $<

devices:
	rm -f /dev/kolter_1616.*
	mknod /dev/kolter_1616.0 c $(MAJOR) 0
	mknod /dev/kolter_1616.1 c $(MAJOR) 1
	mknod /dev/kolter_1616.2 c $(MAJOR) 2
	mknod /dev/kolter_1616.3 c $(MAJOR) 3
	mknod /dev/kolter_1616.4 c $(MAJOR) 4
	mknod /dev/kolter_1616.5 c $(MAJOR) 5
	mknod /dev/kolter_1616.6 c $(MAJOR) 6
	mknod /dev/kolter_1616.7 c $(MAJOR) 7
	chmod a+rw /dev/kolter_1616.*

install: module
	install -d $(MODULEDIR)
	install -m u=rw,g=r,o=r $(MODNAME) $(MODULEDIR)

clean:
	rm -fR *~ $(MODNAME) $(TESTPROG) $(TMPFILES)

endif # ifneq($(KERNELRELEASE),)
