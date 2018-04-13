// $fn = 60;
pi = 3.1415926;

pitch = 2;   // 2GT timing belt

a = 0.4;

module tooth(h) {
    M1 = [[ 1  , a , 0  , 0   ],
           [ 0  , 2 , 0  , 0   ],
           [ 0  , 0 , 1  , 0   ],
           [ 0  , 0 , 0  , 1   ] ] ;
    M2 = [[ 1  , -a , 0  , 0   ],
           [ 0  , 2  , 0  , 0   ],
           [ 0  , 0  , 1  , 0   ],
           [ 0  , 0  , 0  , 1   ] ] ;
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

// beltdrive(62, 3, 0.6);
// tooth(3);
// translate([-0.6, 1.5, 0]) cube([0.7, 1, 1]);
