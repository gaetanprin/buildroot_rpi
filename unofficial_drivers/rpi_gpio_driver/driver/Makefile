# Run this Makefile as follows:
# (MAKE) -C $(KDIR) SUBDIRS=$(PWD) modules
#

KDIR=$(LINUX_DIR)

PWD= $(shell pwd)

obj-m := rpi_gpio_drv.o

all:
	$(MAKE) -C $(KDIR) SUBDIRS=$(PWD) modules
	$(MAKE) -C $(KDIR) SUBDIRS=$(PWD) modules_install
	depmod -a

only:
	$(MAKE) -C $(KDIR) SUBDIRS=$(PWD) modules

install:
	$(MAKE) -C $(KDIR) SUBDIRS=$(PWD) modules_install
	depmod -a

clean:
	rm -f *~ Module.markers Modules.symvers
	$(MAKE) -C $(KDIR) SUBDIRS=$(PWD) clean

