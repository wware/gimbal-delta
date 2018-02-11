$fn=60;

CONE_DIMENSION=26.5;
TIMING_BELT_WIDTH=3;
DIMPLE=1;
GIMBAL_OUTER_DIAMETER=2*19.266;
GIMBAL_HEIGHT=16;  // ???

module gimbal() {
    translate([0, 0, -.5 * GIMBAL_HEIGHT])
    cylinder(d=GIMBAL_OUTER_DIAMETER, h=GIMBAL_HEIGHT);
}

module bearing_684zz() {
    difference() {
        translate([0, 0, -2]) cylinder(h=4, d=9);
        translate([0, 0, -3]) cylinder(h=6, d=4);
    }
}

module bearing_608zz() {
    difference() {
        translate([0, 0, -3.5]) cylinder(h=7, d=22);
        translate([0, 0, -4]) cylinder(h=8, d=8);
    }
}

module bearings() {
    C = 6.5 / sqrt(2);
    for (i = [0 : 2]) {
        a = 0.5 * GIMBAL_OUTER_DIAMETER + C;
        b = C + 4.5;
        rotate(30 + 120*i, [0, 0, 1]) {
            translate([a, 0, -b]) rotate(45, [0, 1, 0])
                bearing_684zz();
            translate([a, 0, b]) rotate(45, [0, -1, 0])
                bearing_684zz();
        }
    }
}

module post_pair() {
    C = 6.5 / sqrt(2);
    a = 0.5 * GIMBAL_OUTER_DIAMETER + C;
    b = C + 4.5;
    for (j = [0 : 1]) {
        rotate(j*180, [1, 0, 0])
            translate([0, 0, b]) rotate(45, [0, -1, 0]) {
                translate([0, 0, -6]) cylinder(d=4, h=8);
                translate([0, 0, -6]) cylinder(d=5, h=4);
            }
    }
    translate([-2.5, 0, 0])
        intersection() {
            rotate(45, [0, 1, 0])
                translate([0, -5, 0])
                    cube([20, 10, 12]);
            translate([3.5, -50, -50])
                cube(100, 100, 100);
        }
    translate([7, -5, -15])
        cube([20, 10, 10]);
}

module posts() {
    C = 6.5 / sqrt(2);
    a = 0.5 * GIMBAL_OUTER_DIAMETER + C;
    for (i = [0 : 2])
    rotate(30 + 120*i, [0, 0, 1]) translate([a, 0, 0]) post_pair();
}

module cylinder_ring(inner, middle, outer) {
    difference() {
        cylinder(d1=outer, d2=middle, h=0.5*(outer-middle));
        translate([0, 0, -1])
        cylinder(d=inner, h=(2+outer-middle));
    }
}

module gimbal_with_rings() {
    D = 4 * sqrt(2);
    b = 4.5;
    small = 1;  // don't want the timing belt to bind
    gimbal();
    translate([0, 0, b])
    cylinder_ring(GIMBAL_OUTER_DIAMETER - 0.1,
        GIMBAL_OUTER_DIAMETER,
        GIMBAL_OUTER_DIAMETER + D);
    translate([0, 0, 3 + small])
    difference() {
        cylinder(d=GIMBAL_OUTER_DIAMETER + D, h = 1.5 - small);
        translate([0, 0, -0.001])
        cylinder(d=GIMBAL_OUTER_DIAMETER - 0.001, h = 1.6);
    }

    translate([0, 0, -b])
    rotate(180, [1, 0, 0])
    cylinder_ring(GIMBAL_OUTER_DIAMETER - 0.1,
        GIMBAL_OUTER_DIAMETER,
        GIMBAL_OUTER_DIAMETER + D);
    translate([0, 0, -4.5 - 0.001])
    difference() {
        cylinder(d=GIMBAL_OUTER_DIAMETER + D, h = 1.5 - small);
        translate([0, 0, -0.001])
        cylinder(d=GIMBAL_OUTER_DIAMETER - 0.001, h = 1.6);
    }
}

if (1) {
    %bearings();
    gimbal_with_rings();
    posts();
} else {
    post_pair();
}
