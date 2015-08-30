CC= $(CROSS_COMPILE)gcc
CFLAGS= -O2 -I../driver

PROG= rpi_gpio

OBJS= $(PROG).o

all: $(PROG)

$(PROG): $(OBJS)
	$(CC) $(CFLAGS) -o $(PROG) $(OBJS) -lrt 

clean:
	rm -f *~ $(OBJS)  $(PROG)

install: $(PROG)
	cp $(PROG) $(STAGING_DIR)/usr/bin
