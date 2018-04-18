$fn=60;

include <gimbal1.scad>;
include <beltdrive.scad>;

GIMBAL_OUTER_DIAMETER = 2 * R5;
GIMBAL_HEIGHT =  thirdHeight;
RING_OFFSET = 4.7;

module bearing_tool() {
    W = 25;
    L = 50;
    cylinder(h=30, d1=W, d2=8);
    cylinder(h=L+1, d=4);
    cylinder(h=L, d=8);
};

bearing_tool();
