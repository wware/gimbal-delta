UNAME := $(shell uname -a)
ifneq (,$(findstring raspberrypi,$(UNAME)))
	# Running on Raspberry Pi
	DEFINES=-DRASPBERRY_PI
	LIBS=-lbcm2835 -lrt
	DEPENDENCY=
else
	# Running on desktop or laptop
	DEPENDENCY=sim_bcm2835.o
endif

all: motor motor.so

sim_bcm2835.o: sim_bcm2835.c
	gcc -g -Wall -c -o sim_bcm2835.o sim_bcm2835.c

motor: motor.c $(DEPENDENCY)
	gcc -g -Wall $(RASPBERRY_PI) -DMOTORMAIN=1 -o motor motor.c $(LIBS) $(DEPENDENCY)

motor.so: motor.c $(DEPENDENCY)
	gcc -shared -g -Wall $(RASPBERRY_PI) -o motor.so motor.c $(LIBS) $(DEPENDENCY)

clean:
	rm -f motor motor.so sim_bcm2835.o
