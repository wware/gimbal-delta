// $fn = 60;
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

//GimbalNut();
//GimbalNutBearings();
