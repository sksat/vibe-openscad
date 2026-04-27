$fn = 100;

difference() {
    union() {
        // 外側の円筒
        cylinder(h = 100, d = 80);
        
        // 取手（リング状）
        translate([40, 0, 50])
        rotate([90, 0, 0])
        rotate_extrude(convexity = 10)
        translate([12, 0, 0])
        circle(d = 8);
    }
    
    // 内側のくり抜き
    translate([0, 0, 6])
    cylinder(h = 100, d = 80 - 8);
}