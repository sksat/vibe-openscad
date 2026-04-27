$fn = 100;

difference() {
    union() {
        // 外側の円筒
        cylinder(h = 100, d = 80);
        
        // 取手（リング状）
        translate([40 + 12, 0, 50])
        rotate([0, 90, 0])
        difference() {
            torus(20, 6);
        }
    }
    
    // 内側のくり抜き
    translate([0, 0, 6])
    cylinder(h = 100, d = 80 - 8);
}

// トーラスモジュール
module torus(major_radius, minor_radius) {
    rotate_extrude(convexity = 10)
    translate([major_radius, 0, 0])
    circle(r = minor_radius);
}