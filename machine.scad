$fn = 30;
INCH = 25.4;

arm_separation = 50;

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

module ToolMountPlatform() {
    // plywood hexagon
    translate([0, 0, -5])
        linear_extrude(height=5)
            circle(100, $fn=6);
    // the router or extruder
    cylinder(d=40, h=40);
    translate([0, 0, -15])
        cylinder(d=10, h=20);
    // 3 pairs of gimbal nuts
    for (n = [1 : 3])
        rotate(120 * n, [0, 0, 1])
            translate([0, 60, 0])
                GimbalNutPair();
}

ToolMountPlatform();

module DriverModule() {
    GimbalNutPair();
    // plywood
    translate([-50, -25, -5])
        cube([100, 110, 5]);
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
        translate([0, 200, 300])
            DriverModule();

// threaded rods connecting driver modules to tool mount
for (n = [1 : 3])
    rotate(120 * n, [0, 0, 1])
        for (m = [0 : 1])
            translate([(m - .5) * arm_separation, 60, 8]) {
                rotate(-25, [1, 0, 0])
                    cylinder(d=5, h=400);
            }
