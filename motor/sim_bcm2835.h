#define LOW  0
#define HIGH 1
#define BCM2835_GPIO_FSEL_OUTP  11

int bcm2835_init(void);
void bcm2835_set_debug(int on);
void bcm2835_gpio_fsel(int pin, int properties);
void bcm2835_gpio_write(int pin, int value);
