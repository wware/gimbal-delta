# What I learned from the fitter piece

The step of 0.25 mm turns out to be too large. The outer dimension
of 9 mm is a bit too snug, but 9.25 mm is way too loose. My guess is
that 9.1 mm might be just right. I think a better step would be 0.05 mm.

Also, there is little need for smaller-than-9-mm sizes. One would be
fine. So my next plan is something like this.

    module ThirdPiece() {
        difference() {
            intersection() {
                ...
            }
            for (n = [-1 : 3])    // note different for-loop limits
                rotate([0, 0, n * 60])
                    rotate([90, 0, 0])
                        translate([0, 0, 0])
                            cylinder(h=60, d=9 + 0.05*n);   // 0.05 mm step
        }
        for (n = [-1 : 3])
            rotate([0, 0, 180 - 30 + n * 60])
                translate([0, R3+5, 0])
                    rotate([-90, 0, 0]) nub(4 + 0.05*n);
    }
