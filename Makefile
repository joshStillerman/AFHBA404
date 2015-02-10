obj-m += afhba.o
obj-m += afhbaspi.o
obj-m += afhbasfp.o

SRC := $(shell pwd)
LDRV:= $(SRC)/linux/drivers


EXTRA_CFLAGS += -DCONFIG_SPI

# default build is the local kernel.
# build other kernels like this example:
# make KRNL=2.6.20-1.2948.fc6-i686 ARCH=i386
# make KRNL=2.6.18-194.26.1.el5 ARCH=i386

all: modules apps spi_support mtd-utils

KRNL ?= $(shell uname -r)
# FEDORA:
KHEADERS := /lib/modules/$(KRNL)/build


afhba-objs = acq-fiber-hba.o \
	afhba_devman.o afhba_debugfs.o afhba_stream_drv.o afhba_sysfs.o \
	afhba_core.o  \
	afs_procfs.o 

afhbaspi-objs = afhba_spi.o afhba_core.o

afhbasfp-objs =  afhba_i2c_bus.o afhba_core.o
	
modules: 
	make -C $(KHEADERS) M=$(SRC)  modules


APPS := mmap xiloader
apps: $(APPS)


mtd-utils:
	cd mtd-utils
	$(MAKE)

mmap:
	cc -o mmap mmap.c -lpopt

xiloader:
	cc -o xiloader xiloader.c -lpopt


spi_support: 
	make -C $(KHEADERS) M=$(LDRV)/spi  obj-m="spi-bitbang.o" modules
	make -C $(KHEADERS) M=$(LDRV)/mtd  obj-m="mtd.o" modules
	make -C $(KHEADERS) M=$(LDRV)/mtd/devices obj-m=m25p80.o modules
	cp ./linux/drivers/mtd/devices/m25p80.ko .
	cp ./linux/drivers/spi/spi-bitbang.ko .
	cp ./linux/drivers/mtd/mtd.ko .

spi_clean:
	make -C $(KHEADERS) M=$(LDRV)/spi clean
	make -C $(KHEADERS) M=$(LDRV)/mtd clean
	make -C $(KHEADERS) M=$(LDRV)/mtd/devices clean
	
clean:
	rm -f *.mod* *.o *.ko modules.order Module.symvers $(APPS) .*.o.cmd

DC := $(shell date +%y%m%d%H%M)
package: clean
	git tag $(DC)
	(cd ..;tar cvf AFHBA/release/afhba-$(DC).tar \
		--exclude=release --exclude=SAFE AFHBA/* )
	
