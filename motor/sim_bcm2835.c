#include <stdio.h>
#include "sim_bcm2835.h"

static int which_step = 0, debugflag = 0;

int bcm2835_init(void) {
	return 1;    // sucess is 1? go figure
}

void bcm2835_set_debug(int on) {
	debugflag = on;
}

void bcm2835_gpio_fsel(int pin, int properties) {
	if (debugflag)
		printf("%d gpio_fsel %d %d\n", which_step++, pin, properties);
}

void bcm2835_gpio_write(int pin, int value) {
	if (debugflag)
		printf("%d gpio_write %d %d\n", which_step++, pin, value);
}
