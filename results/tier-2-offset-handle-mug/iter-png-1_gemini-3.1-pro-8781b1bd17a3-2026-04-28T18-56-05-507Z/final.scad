$fn = 100;

union() {
    // 本体
    difference() {
        cylinder(h = 90, r = 40);
        translate([0, 0, 6])
            cylinder(h = 90, r = 35);
    }
    
    // 取手
    translate([40, 0, 45])
    rotate([90, 0, 0])
    linear_extrude(height = 15, center = true) {
        difference() {
            // 取手の外側
            union() {
                translate([-3, -23]) square([13, 46]);
                translate([10, 0]) circle(r = 23);
            }
            // 取手の内側の空間
            union() {
                translate([-4, -15]) square([14, 30]);
                translate([10, 0]) circle(r = 15);
            }
        }
    }
}