#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <time.h>
#ifdef RASPBERRY_PI
#include <bcm2835.h>
#else
#include "sim_bcm2835.h"
#endif

#define PULA    21
#define DIRA    20
#define ENAA    16

#define PULB    13
#define DIRB    19
#define ENAB    26

#define PULC    12
#define DIRC    25
#define ENAC    24

#define MAX(x,y)  (((x) > (y)) ? (x) : (y))
#define ABS(x)    MAX(x, -(x))

#define MODULO   100000

// PERIOD is in nanoseconds
#define PERIOD   100000L

struct pinstruct {
    int phase;
    int state;
    int pin;
};

static struct pinstruct astruct = { 0, 0, PULA };
static struct pinstruct bstruct = { 0, 0, PULB };
static struct pinstruct cstruct = { 0, 0, PULC };

void process_pin(struct pinstruct *pstr, int value)
{
    pstr->phase += value;
    if (pstr->phase > MODULO) {
        bcm2835_gpio_write(pstr->pin, pstr->state ? HIGH : LOW);
        pstr->state = !pstr->state;
        pstr->phase %= MODULO;
    }
}

int run_motors(int avalue, int bvalue, int cvalue, int usecs, int enable_debug)
{
    int iter;
    struct timespec ts = {0};

    ts.tv_sec = 0;
    ts.tv_nsec = PERIOD;

    if (enable_debug)
        bcm2835_set_debug(1);

    if (!bcm2835_init())
        return 1;

    bcm2835_gpio_fsel(PULA, BCM2835_GPIO_FSEL_OUTP);
    bcm2835_gpio_fsel(DIRA, BCM2835_GPIO_FSEL_OUTP);
    bcm2835_gpio_fsel(ENAA, BCM2835_GPIO_FSEL_OUTP);

    bcm2835_gpio_fsel(PULB, BCM2835_GPIO_FSEL_OUTP);
    bcm2835_gpio_fsel(DIRB, BCM2835_GPIO_FSEL_OUTP);
    bcm2835_gpio_fsel(ENAB, BCM2835_GPIO_FSEL_OUTP);

    bcm2835_gpio_fsel(PULC, BCM2835_GPIO_FSEL_OUTP);
    bcm2835_gpio_fsel(DIRC, BCM2835_GPIO_FSEL_OUTP);
    bcm2835_gpio_fsel(ENAC, BCM2835_GPIO_FSEL_OUTP);

    bcm2835_gpio_write(ENAA, HIGH);
    bcm2835_gpio_write(DIRA, (avalue < 0) ? HIGH : LOW);
    avalue = ABS(avalue);

    bcm2835_gpio_write(ENAB, HIGH);
    bcm2835_gpio_write(DIRB, (bvalue < 0) ? HIGH : LOW);
    bvalue = ABS(bvalue);

    bcm2835_gpio_write(ENAC, HIGH);
    bcm2835_gpio_write(DIRC, (cvalue < 0) ? HIGH : LOW);
    cvalue = ABS(cvalue);

    for (iter = 0; iter < usecs; iter++) {
        if (enable_debug)
            printf("%d %d %d %d\n", iter, astruct.phase, bstruct.phase, cstruct.phase);
	process_pin(&astruct, avalue);
	process_pin(&bstruct, bvalue);
	process_pin(&cstruct, cvalue);
        nanosleep(&ts, (struct timespec *) NULL);
    }

    bcm2835_gpio_write(ENAA, LOW);
    bcm2835_gpio_write(ENAB, LOW);
    bcm2835_gpio_write(ENAC, LOW);

    return 0;
}

#ifdef MOTORMAIN
const char *helpstring = "MODULO=%d PERIOD=%d\n"
"  Example usage: %s -D 10000 -c 45000\n"
"Command line options\n"
"    -a <n>   rate multiple of the A motor, positive up, negative down\n"
"    -b <n>   rate multiple of the B motor, positive up, negative down\n"
"    -c <n>   rate multiple of the C motor, positive up, negative down\n"
"    -D <n>   duration\n"
"    -h,-?    help\n";

int main(int argc, char **argv)
{
    int c, debugflag = 0, duration = 300;
    int avalue = 0, bvalue = 0, cvalue = 0;

    while ((c = getopt (argc, argv, "?ha:b:c:D:d")) != -1)
        switch (c) {
            case 'h':
            case '?':
                printf(helpstring, MODULO, PERIOD, argv[0]);
                return 0;
            case 'a':
                avalue = atoi(optarg);
                break;
            case 'b':
                bvalue = atoi(optarg);
                break;
            case 'c':
                cvalue = atoi(optarg);
                break;
            case 'D':
                duration = atoi(optarg);
                break;
            case 'd':
                debugflag = 1;
                break;
            default:
                abort();
        }

    return run_motors(avalue, bvalue, cvalue, duration, debugflag);
}
#endif
