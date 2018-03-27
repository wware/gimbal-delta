$fn=60;

include <gimbal1.scad>;
include <beltdrive.scad>;

GIMBAL_OUTER_DIAMETER = 2 * R5;
GIMBAL_HEIGHT =  thirdHeight;
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

module ring_with_posts(offset) {
    width = 36;
    thickness = 4;
    height = 6.5;
    translate([0, 0, -2])
    difference() {
        cylinder(d=width+2*thickness, h=height);
        translate([0, 0, -0.01])
        cylinder(d=width, h=height+0.02);
    };
    for (i = [0:2]) {
        rotate((i+offset)*120, [0,0,1])
            translate([width/2+thickness+2.5, 0, height-4])
            rotate(90, [0,1,0]) post();
    };
};

module full_rotor() {
    a = 7.5;
    intersection() {
        union() {
            translate([0, 0, a])
                ring_with_posts(0);
            translate([0, 0, -a])
                mirror([0,0,1])
                ring_with_posts(1/2);
        };
        translate([0, 0, -12])
            cylinder(h=24, d=100);
    };
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

if (0) {
    gap = 85;
    %translate([0, -gap/2, 0]) full_rotor();
    %translate([0, -gap/2, 0]) bearings();
    %translate([0, gap/2, 0]) full_rotor();
    %translate([0, gap/2, 0]) mirror([0, 1, 0]) bearings();
    all_posts();
}
if (0) {
    // post_pair();
    half_shell();
    %translate([0, 0, -9.3]) full_rotor();
    translate([0, 0, -18.55])
        rotate(180, [0, 1, 0])
            half_shell();
}
if (1) {
    p = 25;
    full_rotor();
    if (0) {
        %cylinder(r1=0, r2=p, h=p);
        %rotate(180, [1,0,0]) cylinder(r1=0, r2=p, h=p);
    }
    translate([30, 16, -12])
        bearing_tool();
    translate([-30, 16, -12])
        bearing_tool();
}
//post();
