$fn=60;
INCH = 25.4;   // all dimensions are in millimeters
WRENCH_SIZE = (7/16) * INCH;   // 1/4-20 nut

// Each gimbal requires four 684ZZ bearings.
// If you can afford a long lead time, you can find
// good bulk prices for these on eBay.
BEARING_INNER = 4;
BEARING_OUTER = 9 + 0.1;
BEARING_THICKNESS = 4;

firstHeight = 10;
secondHeight = 6;
thirdHeight = 16;

R1 = 10;  // Outer radius of the first piece
R2 = // Inner radius of the second piece
    sqrt(pow(R1, 2) + pow(.5 * BEARING_OUTER, 2));
R3 = // Outer radius of the second piece
    sqrt(pow(R1 + BEARING_THICKNESS, 2) +
            pow(.5 * BEARING_OUTER, 2));
R4 = R3 + 1;    // Inner radius of the third piece
R5 = // Outer radius of the third piece
    sqrt(pow(R3 + BEARING_THICKNESS, 2) +
            pow(.5 * BEARING_OUTER, 2));

module nub() {
    translate([0, 0, -2]) {
        // this part fits into the bearing
        cylinder(d=BEARING_INNER, h=6);
        // this keeps the bearing positioned
        cylinder(d=BEARING_INNER+2, h=2);
    }
}

module FirstPiece() {
    // nut holder
    difference() {
        intersection() {
            sphere(d=2*R1);
            translate([0,0,-.5*firstHeight])
                cylinder(h=firstHeight, d=20);
        }
        // hex cut-out for the nut
        intersection_for(n = [1 : 3])
            rotate(60 * n, [0, 0, 1])
                translate([-0.5 * WRENCH_SIZE, -12, -12])
                    cube([WRENCH_SIZE, 24, 24]);
    }
    // a surface for the nut to rest against with a
    // hole for the threaded rod to pass thru
    difference() {
        translate([0, 0, -5])
            cylinder(h=4, d=2*R1-3);
        translate([0, 0, -6])
            cylinder(h=25, d=8);   // a little bigger than 1/4"
    }
    // nubs for the two inner bearings
    translate([R1, 0, 0]) rotate([0, 90, 0]) nub();
    translate([-R1, 0, 0]) rotate([0, -90, 0]) nub();
}

module SecondPiece() {
    difference() {
        intersection() {
            difference() {
                sphere(d=2*R3);
                sphere(d=2*R2);
            }
            // limit height but leave material
            // around the inner bearings
            union() {
                translate([-20, -20, -.5*secondHeight])
                    cube([40, 40, secondHeight]);
                for (n = [0 : 2])
                    rotate(90 * (2*n - 1), [0, 1, 0])
                        cylinder(h=20, r1=0, r2=14);
            }
        }
        // cut-outs for two inner bearings
        translate([12, 0, 0])
            rotate([0, 90, 0])
                translate([0, 0, -45])
                    cylinder(h=60, d=9);
    }
    // nubs for the two outer bearings
    translate([0, R3, 0]) rotate([-90, 0, 0]) nub();
    translate([0, -R3, 0]) rotate([90, 0, 0]) nub();
}

module ThirdPiece() {
    difference() {
        intersection() {
            difference() {
                translate([0, 0, -.5*thirdHeight])
                    cylinder(d=2*R5, h=thirdHeight);
                translate([0, 0, -20])
                    cylinder(d=2*R4, h=40);
            }
        }
        // cutouts for the two bearings
        rotate([90, 0, 0])
            translate([0, 0, -30])
                cylinder(h=60, d=9);
    }
    translate([0, R3, 0]) rotate([-90, 0, 0]) nub();
    translate([0, -R3, 0]) rotate([90, 0, 0]) nub();
}

module Bearing() {
    translate([0, 0, -2])
        difference() {
            cylinder(h=BEARING_THICKNESS,
                        d=BEARING_OUTER);
            translate([0, 0, -0.1])
                cylinder(h=BEARING_THICKNESS+1,
                            d=BEARING_INNER);
        }
}

module GimbalNut() {
    FirstPiece();
    SecondPiece();
    ThirdPiece();
}

module GimbalNutBearings() {
    translate([R1 + 2, 0, 0]) rotate([0, 90, 0]) Bearing();
    translate([-R1 - 2, 0, 0]) rotate([0, 90, 0]) Bearing();
    translate([0, R3 + 2, 0]) rotate([90, 0, 0]) Bearing();
    translate([0, -R3 - 2, 0]) rotate([90, 0, 0]) Bearing();
}

module tooth(h) {
    a = 0.4;
    M1 = [ [ 1  , a , 0  , 0 ],
           [ 0  , 2 , 0  , 0 ],
           [ 0  , 0 , 1  , 0 ],
           [ 0  , 0 , 0  , 1 ] ] ;
    M2 = [ [ 1  , -a , 0  , 0 ],
           [ 0  , 2  , 0  , 0 ],
           [ 0  , 0  , 1  , 0 ],
           [ 0  , 0  , 0  , 1 ] ] ;
    translate([-1, -0.5, -h/2])
        intersection() {
            multmatrix(M1) {
                cube(size=[1.5,1,h]);
            }
            multmatrix(M2) {
                cube(size=[1.5,1,h]);
            }
        }
}

module beltdrive(N, h, w) {
    b = 0.6;
    r = (1 / sin(180 / N)) - 1.5;
    echo(r);
    echo(r-w);
    difference() {
        translate([0, 0, -h/2])
            cylinder(r=r, h=h);
        translate([0, 0, -h/2-1])
            cylinder(r=r-w, h=h+2);
    }
    for (i = [0 : N-1]) {
        rotate(i * 360 / N, [0, 0, 1])
            translate([0, r, 0])
                tooth(h);
    }
}

/* To avoid a "wall too thin" warning from Shapeways, you need the
   outer edge of the tooth to be at least 0.7 mm thick. This requires
   dropping the value of a to 0.4.
 */

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

module plywood_parts() {
    for (j = [0 : 2])
        translate([0, 202*j, 3])
            plywood_driver_base();
    translate([0, -275, -3])
        tool_platform();
}

//full_rotor();
//fixed_gimbal();
//driver_module();
//plywood_driver_base();
//tensioner_belt_follower();
//tensioner_pieces();
//tool_platform(1);

//plywood_parts();
projection(cut=true) plywood_parts();
