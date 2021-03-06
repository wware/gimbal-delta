$fn = 30;
INCH = 25.4;

arm_separation = 70;
driver_width = arm_separation + 60;

// http://reprap.org/wiki/NEMA_17_Stepper_motor
nema17height = 50;    // approximate
nema17width = 42.3;

module GimbalNut() {
    translate([0, 0, -0.01])
        cylinder(r=19.2, h=16);
}

module GimbalNutPair() {
    translate([-.5 * arm_separation, 0, 0])
        GimbalNut();
    translate([.5 * arm_separation, 0, 0])
        GimbalNut();
}

module dewalt660router() {
    // http://www.dewalt.com/products/power-tools/cutout-tools/cutout-tool/dw660
    cylinder(d=3*INCH, h=10*INCH);
    translate([0, 0, -25])
        cylinder(d=15, h=30);
}

hex_diameter = 150;

module ToolMountPlatform() {
    dewalt660router();
    // plywood hexagon
    translate([0, 0, -5])
        linear_extrude(height=5)
            circle(hex_diameter, $fn=6);
    // 3 pairs of gimbal nuts
    for (n = [1 : 3])
        rotate(120 * n, [0, 0, 1])
            translate([0, 100, 0])
                GimbalNutPair();
}

ToolMountPlatform();

module DriverModule() {
    GimbalNutPair();
    // plywood
    translate([-.5*driver_width, -25, -5])
        cube([driver_width, 110, 5]);
    // stepper motor
    translate([-.5*nema17width,
              50 - .5*nema17width,
              -nema17height - 5])
        cube([nema17width, nema17width, nema17height]);
    // stepper motor shaft
    translate([0, 50, 0])
        cylinder(d=0.4*INCH, h=24);
}

// there needs to be a frame to hold the 3 driver modules
for (n = [1 : 3])
    rotate(120 * n, [0, 0, 1])
        translate([0, 380, 600])
            DriverModule();

// threaded rods connecting driver modules to tool mount
for (n = [1 : 3])
    rotate(120 * n, [0, 0, 1])
        for (m = [0 : 1])
            translate([(m - .5) * arm_separation, 100, 8]) {
                rotate(-25, [1, 0, 0])
                    cylinder(d=5, h=36*INCH);
            }
