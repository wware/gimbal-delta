$fn=60;

include <gimbal1.scad>;
include <beltdrive.scad>;

GIMBAL_OUTER_DIAMETER = 2 * R5;
GIMBAL_HEIGHT = thirdHeight;
RING_OFFSET = 4.7;

module gimbal_outline() {
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
    // 6.5 = (9 + 4) / 2, from the bearing
    C = 6.5 / sqrt(2);
    for (i = [0 : 2]) {
        a = 0.5 * GIMBAL_OUTER_DIAMETER + C;
        b = C + RING_OFFSET;
        rotate(30 + 120*i, [0, 0, 1]) {
            translate([a, 0, -b]) rotate(45, [0, 1, 0])
                bearing_684zz();
            translate([a, 0, b]) rotate(45, [0, -1, 0])
                bearing_684zz();
        }
    }
}

module half_shell() {
    w = 23.9;
    intersection() {
        for (j = [0 : 3]) {
            rotate((j+.25)*90, [0, 0, 1])
            translate([w, 0, 0])
                rotate(45, [0, -1, 0]) {
                    h1 = 4;
                    h2 = 2.4;
                    %bearing_684zz();
                    translate([0, 0, -2-0.01])
                        cylinder(d=4, h=4+0.02);
                    translate([0, 0, -(h2+2)])
                        cylinder(d=6, h=h2);
                };
        };
    };
    h = 5;
    difference() {
        k = 12;
        translate([0, 0, -5.1+.01])
            cylinder(r=w+1+k+h, h=h-0.02);
        translate([0, 0, -5.1])
            cylinder(r=w+1+h, h=h);
        for (i = [0 : 3]) {
            rotate(i * 90, [0, 0, 1])
                translate([w+10, 0, -100])
                    // 8-32 machine screw
                    cylinder(d=0.164*25.4, h=200);
        }
    };
    difference() {
        translate([0, 0, -5.1+.01])
            cylinder(r=w+1+h, h=h-0.02);
        translate([0, 0, -5.1])
            cylinder(r1=w+1, r2=w+1+h, h=h);
    };
};


module post() {
    extra = 2;
    translate([0, 0, -(2+extra)]) {
        cylinder(d=4, h=4+extra);
        cylinder(d=5, h=extra);
    };
    %bearing_684zz();
};

module post_pair() {
    C = 6.5 / sqrt(2);
    a = 0.5 * GIMBAL_OUTER_DIAMETER + C;
    b = C + RING_OFFSET;
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

module flat_head_screw_cutout(D, H, L) {
    // https://tinyurl.com/ybmmaz7t - dimensions
    D = 3; H = 1.7; L = 10;  // M3
    translate([0, 0, -(D+H)/2])
        cylinder(d1=0, d2=D+H+2, h=(D+H)/2+1);
    translate([0, 0, -L])
        cylinder(d=D, h=L);
};

module m3_cutout(L) { flat_head_screw_cutout(3, 1.7, L); };
module m4_cutout(L) { flat_head_screw_cutout(4, 2.3, L); };
module m5_cutout(L) { flat_head_screw_cutout(5, 2.8, L); };
module m6_cutout(L) { flat_head_screw_cutout(6, 3.3, L); };

module posts() {
    C = 6.5 / sqrt(2);
    a = 0.5 * GIMBAL_OUTER_DIAMETER + C;
    for (i = [0 : 2])
        rotate(30 + 120*i, [0, 0, 1])
            translate([a, 0, 0])
                post_pair();
    translate([0, 0, -19.99])
    difference() {
        cylinder(h=5, d=103);
        union() {
            translate([0, 0, -1])
                cylinder(h=7, d=65);
            translate([-125, -15, -1])
                cube([250, 1, 7]);
            translate([33, -28, 5])
                m5_cutout(15);
            translate([-33, -28, 5])
                m5_cutout(15);
            translate([42, -3, 5])
                m5_cutout(15);
            translate([-42, -3, 5])
                m5_cutout(15);
            translate([15, 42.5, 5])
                m5_cutout(15);
            translate([-15, 42.5, 5])
                m5_cutout(15);
        };
    };
}

module cylinder_ring(inner, middle, outer) {
    difference() {
        cylinder(d1=outer, d2=middle, h=0.5*(outer-middle));
        translate([0, 0, -1])
        cylinder(d=inner, h=(2+outer-middle));
    }
}

module with_rings() {
    D = 4 * sqrt(2);
    translate([0, 0, RING_OFFSET])
    cylinder_ring(GIMBAL_OUTER_DIAMETER - 0.1,
        GIMBAL_OUTER_DIAMETER,
        GIMBAL_OUTER_DIAMETER + D);

    translate([0, 0, -RING_OFFSET])
    rotate(180, [1, 0, 0])
    cylinder_ring(GIMBAL_OUTER_DIAMETER - 0.1,
        GIMBAL_OUTER_DIAMETER,
        GIMBAL_OUTER_DIAMETER + D);
}

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

module rotor_cross_section() {
    intersection() {
        full_rotor();
        translate([-500, -500, -1000])
            cube([1000, 1000, 1000]);
    }
}

module all_posts() {
    gap = 85;
    translate([0, -gap/2, 0]) posts();
    translate([0, gap/2, 0]) mirror([0, 1, 0]) posts();
};

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
nema17height = 50;    // approximate
nema17width = 42.3;
nema17shaft = 5;
nema17shaftring = 23;
nema17screwoffset = 16.5;
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
    w = 250;
    w = 350;
    d = 200;
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
        translate([-110, -50, -10]) cylinder(d=4, h=15);
        translate([-80, -50, -10]) cylinder(d=4, h=15);
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
    r = 200;
    tool_hole_diameter = 100;
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

//full_rotor();
//fixed_gimbal();
driver_module();
//plywood_driver_base();
//tensioner_belt_follower();
//tensioner_pieces();
//tool_platform(1);

if (0) {
    plywood_driver_base();
    translate([0, -275, 0])
        tool_platform();
}
