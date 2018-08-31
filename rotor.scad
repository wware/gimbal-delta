
$fn=60;

include <gimbal1.scad>;
include <beltdrive.scad>;

GIMBAL_HEIGHT = thirdHeight;

module ring(thickness, height) {
    width = 36;
    translate([0, 0, -2])
        difference() {
            cylinder(d=width+2*thickness, h=height);
            translate([0, 0, -1])
                cylinder(d=width, h=height+2);
        };
};

module full_rotor() {
    a = 7.5;
    translate([0, 0, a])  ring(4, 4);
    translate([0, 0, -a]) ring(4, 4);
    GimbalNut();
    difference() {
        translate([0, 0, -0.05])
        beltdrive(66, 12.1, 0.6);
        rotate(90, [1, 0, 0])
            translate([0, 0, -25])
                cylinder(h=50, d=10);
    }
}

module bearing_tool() {
    W = 20;
    L = 30;
    gap = 3;
    cylinder(h=5, d=W);
    cylinder(h=L+2, d=4);
    cylinder(h=L, d=8);
};

fixed_screw_diameter = 6.35;

module fixed_gimbal() {
    a = 12;
    translate([0, 0, -a]) ring(5, 9);
    GimbalNut();
    for (j = [0 : 4]) {
        rotate(j* 90, [0, 0, 1])
            difference() {
                translate([21, -7, -14])
                    cube([18, 14, 5]);
                translate([32, 0, -14.1])
                    cylinder(d=fixed_screw_diameter, h=6);
        }
    }
}

red = [1, 0.4, 0.4];
green = [0.4, 1, 0.4];
blue = [0.6, 0.6, 1];

susan_h = 6;
susan_r = 51;
susan_br = 46;    // distance of mounting bolt from center
susan_bd = 4.2;   // diameter of mounting bolt
lazy_susan_separation = 2 * susan_r + 10;

module lazy_susan() {
    translate([0, 0, 0.5 * GIMBAL_HEIGHT + susan_h - 0.01])
        full_rotor();
    difference() {
        cylinder(r=susan_r, h=susan_h);
        translate([0, 0, -1])
            cylinder(r=16, h=susan_h+2);
        for (i = [0 : 3])
            rotate(90*i, [0, 0, 1])
                translate([susan_br, 0, -0.01])
                    cylinder(h=susan_h+1, d=susan_bd);
    }
}

module tensioner_belt_follower() {
    difference() {
        union() {
            beltdrive(24, 18, 1.6);
            translate([0, 0, -9])
                cylinder(d=20, h=4);
            translate([0, 0, 5])
                cylinder(d=20, h=4);
        }
        translate([0, 0, -10])
            cylinder(d=6, h=20);
        // make sure we can get the bearings in there
        translate([0, 0, -10.01])
            cylinder(d=9.2, h=4);
        translate([0, 0, 10.01-4])
            cylinder(d=9.2, h=4);
    }
}

// http://reprap.org/wiki/NEMA_17_Stepper_motor
// The ones I actually got were more like https://www.adafruit.com/product/324
nema17height = 50;    // approximate
nema17width = 42.3;
nema17shaft = 5;
nema17shaftring = 25;
nema17screwoffset = 15.5;
nema17screwdiameter = 3;  // M3 screw

module gimbal_pair(option) {
    if (option == 0) {    // holes for fixed gimbals
        for (j = [0 : 1])
            translate([(2*j-1)*(.5*lazy_susan_separation), 0.5*susan_r, 0]) {
                // four screw mounts
                rotate(45, [0, 0, 1])
                    for (i = [0 : 3])
                        rotate(90*i, [0, 0, 1])
                            translate([32, 0, -10])
                                cylinder(h=30, d=fixed_screw_diameter);
                // hole in middle
                translate([0, 0, -10])
                    cylinder(h=30, d=40);
            }
    }
    else if (option == 1) {    // holes for belt-driven gimbals
        for (j = [0 : 1])
            translate([(2*j-1)*(.5*lazy_susan_separation), 0.5*susan_r, 0]) {
                // four screw mounts
                rotate(45, [0, 0, 1])
                    for (i = [0 : 3])
                        rotate(90*i, [0, 0, 1])
                            translate([susan_br, 0, -10])
                                cylinder(h=30, d=susan_bd);
                // big hole to pass threaded rod
                translate([0, 0, -10])
                    cylinder(h=30, d=45);
            }
    }
    else if (option == 2) {
        // fixed gimbals
        for (i = [0 : 1])
            translate([(2*i-1)*(.5*lazy_susan_separation), 0.5*susan_r, -0.01])
                rotate(45, [0, 0, 1])
                    translate([0, 0, 14])
                        fixed_gimbal();
    }
    else if (option == 3) {
        // belt-driven gimbals
        for (i = [0 : 1])
            translate([(2*i-1)*(.5*lazy_susan_separation), 0.5*susan_r, -0.01])
                rotate(45, [0, 0, 1])
                    lazy_susan();
    }
}

module plywood_driver_base() {
    w = 750;
    d = 300;
    h = 6;
    difference() {
        translate([-w/2, -d/2, -h])
            cube([w, d, h]);
        // lazy susan holes
        gimbal_pair(1);
        // stepper motor holes
        translate([40, -55, 0]) {
            nmea17stepper();
        }
        // screw mounts for tensioner anchor block
        translate([-130, -90, -10]) cylinder(d=4, h=15);
        translate([-100, -70, -10]) cylinder(d=4, h=15);
        // angle cut-outs for the ends, to line up with the 2x4s
        translate([w/2 - 100*sqrt(3), -d/2, -10])
            rotate(-30, [0, 0, 1])
                cube([1000, 1000, 30]);
        translate([-w/2 + 100*sqrt(3), -d/2, -10])
            rotate(30, [0, 0, 1])
                translate([-1000, 0, 0])
                    cube([1000, 1000, 30]);
        // carriage bolts to connect to 2x4s
        translate([-310, 110, -10]) cylinder(d=6.35, h=30);
        translate([310, 110, -10]) cylinder(d=6.35, h=30);
        translate([-170, -80, -10]) cylinder(d=6.35, h=30);
        translate([170, -80, -10]) cylinder(d=6.35, h=30);
    }
}

module nmea17stepper(option) {
    if (option) {
        // stepper motor
        translate([-.5*nema17width, -.5*nema17width, -nema17height - 5])
            cube([nema17width, nema17width, nema17height]);
        // stepper motor shaft
        cylinder(d=nema17shaft, h=24);
    } else {
        // screw holes
        for (i = [0 : 1])
            for (j = [0 : 1])
                translate([(2*i-1) * nema17screwoffset, (2*j-1) * nema17screwoffset, -10])
                    cylinder(d=nema17screwdiameter, h=30);
        // shaft including ring around shaft
        translate([0, 0, -10])
            cylinder(d=nema17shaftring, h=30);
    }
}

module driver_module() {
    color(blue)
        translate([40, -55, 0])
            nmea17stepper(1);

    color(red)
        gimbal_pair(3);

    %plywood_driver_base();

    // this block is an anchor for the tensioner
    color(blue)
        translate([-120, -65, 0])
            cube([50, 30, 30]);

    translate([-25, -50, 14]) {
        color(red)
            tensioner_belt_follower();
        color(green)
            // bearings for tensioner belt follower
            translate([0, 0, -9])
                difference() {
                    cylinder(h=18, d=9);
                    translate([0, 0, -1])
                        cylinder(h=20, d=4);
                }
    }
}

module tool_platform(gimbals) {
    h = 6;
    r = 220;
    tool_hole_diameter = 6 * 25.4;
    screw_mount_spacing = tool_hole_diameter/2 + 20;
    screw_mount_diameter = 6.35;
    difference() {
        cylinder(r=r, h=h, $fn=6);   // hexagon
        for (i = [0 : 2])
            rotate(120*i, [0, 0, 1])
                translate([0, r - 100, 0])
                    gimbal_pair(0);
        translate([0, 0, -10])
            cylinder(d=tool_hole_diameter, h=30);
        for (i = [0 : 3])
            rotate(45 + 90*i, [0, 0, 1])
                translate([screw_mount_spacing, 0, -10])
                    cylinder(d=screw_mount_diameter, h=30);
    }
    if (gimbals) {
        color(red)
            for (i = [0 : 2])
                rotate(120*i, [0, 0, 1])
                    translate([0, r - 100, h])
                        gimbal_pair(2);
    }
}

module tensioner_pieces() {   // 3d-print three at a time
    for (j = [0 : 2]) {
        translate([0, j * 22, 0]) {
            tensioner_belt_follower();
        }
    }
}

module check_driver_module_alignment() {
    driver_module();
    translate([0, 0, -70])
        plywood_driver_base();
}

module plywood_parts() {
    for (j = [0 : 2])
        translate([0, 310*j, 3])
            plywood_driver_base();
    translate([0, -350, -3])
        tool_platform();
    if (0) {
        L = 24 * 25.4;
        W = 48 * 25.4;
        xofs = -225;
        yofs = 200;
        %translate([xofs - W/2, yofs - L/2, 0])
            cube([W, L, 5]);
    }
}

gap = 180;   // purely empirical?

// minimum stick length is 52.3 inches, else drivers overlap
// stick_length = 48 + (gap/25.4);
stick_length = 60 + (gap/25.4);    // 60-inch long 2x4

module three_drivers() {
    L = stick_length * 25.4;
    for (i = [0 : 2])
        rotate((60+120*i), [0, 0, 1])
            translate([0, -L/sqrt(3) + 400, 0])
                plywood_driver_base();
        %for (i = [0 : 2])
            rotate(120*i, [0, 0, 1])
                translate([-L/2+gap/2,
                           -0.5*L/sqrt(3)-50,
                           -6 - 2*25.4])
                    cube([L-gap, 4*25.4, 2*25.4]);
}

module threaded_rod(offset, direc, length) {
    xcomp = direc[0];
    ycomp = direc[1];
    zcomp = direc[2];
    crossLength = sqrt(xcomp * xcomp + ycomp * ycomp);
    theta = atan2(crossLength, zcomp);
    translate(offset)
        rotate(theta, [-ycomp, xcomp, 0])
            cylinder(h=length, d=0.25*25.4);
}

module whole_thing() {
    ydelta = stick_length / sqrt(3) - 22;
    slope = [0, ydelta, 30];
    translate([0, 0, 30*25.4])
        three_drivers();
    tool_platform(0);
    for (i = [0 : 2])
        rotate(120*i, [0, 0, 1]) {
            threaded_rod(
                [0.5*lazy_susan_separation, 140, 0],
                slope,
                48 * 25.4
            );
            threaded_rod(
                [-0.5*lazy_susan_separation, 140, 0],
                slope,
                48 * 25.4
            );
        }
}


//full_rotor();
//fixed_gimbal();
//driver_module();
//plywood_driver_base();
//tensioner_belt_follower();
//tensioner_pieces();
//tool_platform(1);
//three_drivers();
whole_thing();

//plywood_parts();
//projection(cut=true) plywood_parts();

// https://gist.github.com/wware/875998248c23ebd86668fd5c354ec737
// I wish this were a real programming language.
