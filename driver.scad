$fn=60;

use <rotor.scad>;

// height of the lazy susan
h = 6;

module lazy_susan() {
    w = 60;
    w2 = 50;
    difference() {
        translate([0, 0, .5*h])
            cube([w, w, h], center=true);
        translate([.5*w2, .5*w2, .5*h])
            cylinder(d=6, h=h+1, center=true);
        translate([.5*w2, -.5*w2, .5*h])
            cylinder(d=6, h=h+1, center=true);
        translate([-.5*w2, .5*w2, .5*h])
            cylinder(d=6, h=h+1, center=true);
        translate([-.5*w2, -.5*w2, .5*h])
            cylinder(d=6, h=h+1, center=true);
    }
    // the lazy susan upper piece rotates and can bump things
    %translate([0, 0, .5*h])
        cylinder(d=sqrt(2)*w, h=h-1, center=true);
}

module mounted_rotor() {
    translate([0, 0, h-0.01])
        full_rotor();
    lazy_susan();
}

translate([-45, 0, 0]) mounted_rotor();
translate([45, 0, 0]) mounted_rotor();
