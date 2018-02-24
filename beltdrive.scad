$fn = 60;
pi = 3.1415926;

pitch = 2;   // 2GT timing belt

module tooth(h) {
    extra = 0.3;
    translate([-0.45, -extra, -h/2])
        cube([0.9, 0.6 + extra, h]);
    translate([-0.3, 0, -h/2])
        cube([0.6, 0.749, h]);
    translate([-0.3, 0.6, -h/2])
        cylinder(h=h, r=0.15);
    translate([0.3, 0.6, -h/2])
        cylinder(h=h, r=0.15);
}

module beltdrive(N, h, w) {
    b = 0.6;
    r = N * pitch / (2 * pi);
    echo(r);
    echo(r-w);
    difference() {
        translate([0, 0, -h/2])
            cylinder(r=r, h=h);
        translate([0, 0, -h/2-0.01])
            cylinder(r=r-w, h=h+0.02);
    }
    for (i = [0 : N-1]) {
        rotate(i * 360 / N, [0, 0, 1])
            translate([r, 0, 0])
                tooth(h);
    }
}

beltdrive(62, 3, 0.6);