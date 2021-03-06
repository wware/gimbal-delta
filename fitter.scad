$fn = 60;
INCH = 25.4;   // all dimensions are in millimeters
WRENCH_SIZE = (7/16) * INCH;   // 1/4-20 nut

// The sizes of the nubs and cutouts were stepped by
// this many millimeters.
STEPSIZE = 0.05;

// Each gimbal requires four 684ZZ bearings.
// If you can afford a long lead time, you can find
// good bulk prices for these on eBay.
WIGGLE = 0.5;   // half? quarter?
BEARING_INNER = 4 - WIGGLE;
BEARING_OUTER = 9 + WIGGLE;
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

module nub(bearing_inner) {
    translate([0, 0, -2]) {
        // this part fits into the bearing
        cylinder(d=bearing_inner, h=6);
        // this keeps the bearing positioned
        cylinder(d=bearing_inner+2, h=2);
    }
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
        for (n = [-1 : 3]) {
            dim = 9 + STEPSIZE * n;
            echo(dim);
            rotate([0, 0, 4 * 60 + 30 + n * 60])
                rotate([90, 0, 0])
                    translate([0, 0, 0])
                        cylinder(h=60, d=dim);
        }
    }
    for (n = [-1 : 3]) {
        dim = 4 + STEPSIZE * n;
        echo(dim);
        rotate([0, 0, 4 * 60 + 180 + n * 60])
            translate([0, R3+5, 0])
                rotate([-90, 0, 0]) nub(dim);
    }
}

ThirdPiece();
