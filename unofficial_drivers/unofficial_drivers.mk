SUBDIRS= rpi_gpio_drv rpi_gpio_drv_xeno

all::
	for i in  $(SUBDIRS) ;\
        do \
        echo "making all in $$i..."; \
        $(MAKE) -C $$i $(MFLAGS) all; \
        done

clean:
	for i in  $(SUBDIRS) ;\
        do \
        echo "cleaning in $$i..."; \
        $(MAKE) -C $$i $(MFLAGS) clean; \
        done

