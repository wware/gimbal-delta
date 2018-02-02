$fn=60;

CONE_DIMENSION=26.5;
TIMING_BELT_WIDTH=3;
DIMPLE=1;
GIMBAL_OUTER_DIAMETER=2*19.266;
GIMBAL_HEIGHT=16;  // ???

module bearing_608zz() {
    difference() {
        cylinder(h=7, d=22);
        translate([0, 0, -1]) cylinder(h=9, d=8);
    }
}

for (i = [0 : 2]) {
    rotate(120*i, [0, 0, 1]) {
        translate([34.3, 0, TIMING_BELT_WIDTH+15.2])
            rotate(45, [0, -1, 0]) bearing_608zz();
        translate([29.4, 0, -7.2]) rotate(45, [0, 1, 0]) bearing_608zz();
    }
}

difference() {
    union() {
        cylinder(h=GIMBAL_HEIGHT,
            d=GIMBAL_OUTER_DIAMETER+5);
        intersection() {
            translate([0, 0, -CONE_DIMENSION + 5.4]) {
                translate([0,0,(CONE_DIMENSION+TIMING_BELT_WIDTH+2-0.004)])
                cylinder(h=CONE_DIMENSION, r1=CONE_DIMENSION, r2=0);

                translate([0,0,CONE_DIMENSION+1+TIMING_BELT_WIDTH-0.003])
                cylinder(h=1, r2=CONE_DIMENSION,
                    r1=CONE_DIMENSION-DIMPLE);

                translate([0,0,CONE_DIMENSION+1-0.002])
                cylinder(h=TIMING_BELT_WIDTH,
                    r=CONE_DIMENSION-DIMPLE);

                translate([0,0,CONE_DIMENSION-0.001])
                cylinder(h=1, r1=CONE_DIMENSION,
                    r2=CONE_DIMENSION-DIMPLE);

                cylinder(h=CONE_DIMENSION, r1=0, r2=CONE_DIMENSION);
            }
            cylinder(h=GIMBAL_HEIGHT, d=200);
        }
    }
    translate([0, 0, -50])
    cylinder(h=100, d=GIMBAL_OUTER_DIAMETER);
};
