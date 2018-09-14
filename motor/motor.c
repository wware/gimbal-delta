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

int run_motors(int avalue, int bvalue, int cvalue, int usecs, int enable_debug)
{
    int iter, aphase = 0, bphase = 0, cphase = 0;
    int go_a, go_b, go_c;
    struct timespec ts = {0};

    ts.tv_sec = 0;
    ts.tv_nsec = 1000L;   // one microsecond per loop iteration

    // If you call this, it will not actually access the GPIO
    // Use for testing
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

#define N 10000

    for (iter = 0; iter < usecs; iter++) {
        aphase += avalue;
        bphase += bvalue;
        cphase += cvalue;
        go_a = (aphase > N);
        go_b = (bphase > N);
        go_c = (cphase > N);
        if (enable_debug)
            printf("%d %d %d %d\n", iter, aphase, bphase, cphase);
        if (go_a) bcm2835_gpio_write(PULA, HIGH);
        if (go_b) bcm2835_gpio_write(PULB, HIGH);
        if (go_c) bcm2835_gpio_write(PULC, HIGH);
        nanosleep(&ts, (struct timespec *)NULL);
        if (go_a) bcm2835_gpio_write(PULA, LOW);
        if (go_b) bcm2835_gpio_write(PULB, LOW);
        if (go_c) bcm2835_gpio_write(PULC, LOW);
        nanosleep(&ts, (struct timespec *)NULL);
        if (go_a) aphase %= N;
        if (go_b) bphase %= N;
        if (go_c) cphase %= N;
    }

    return 0;
}

#ifdef MOTORMAIN
int main(int argc, char **argv)
{
    int c, debugflag = 0, duration = 300;
    int avalue = 0, bvalue = 0, cvalue = 0;

    while ((c = getopt (argc, argv, "a:b:c:D:d")) != -1)
        switch (c) {
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
