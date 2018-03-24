$fn = 60;

W = 20;
L = 30;
gap = 3;

module tool() {
    cylinder(h=3, d=W);
    cylinder(h=L+1, d=3.8);
    cylinder(h=L, d=8);
};

translate([-W/2 - gap/2, 0, 0]) tool();
translate([+W/2 + gap/2, 0, 0]) tool();
