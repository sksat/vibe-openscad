$fn = 100;

difference() {
    union() {
        // 外側の円筒
        cylinder(h = 100, d = 80);
        
        // 取手
        translate([40, 0, 50])
        rotate([90, 0, 0])
        rotate_extrude(angle = 180, convexity = 10)
        translate([20, 0, 0])
        circle(r = 6);
    }
    
    // 内側のくり抜き
    translate([0, 0, 6])
    cylinder(h = 100, d = 80 - 8);
    
    // 取手の内側のくり抜き
    translate([40, 0, 50])
    rotate([90, 0, 0])
    rotate_extrude(angle = 180, convexity = 10)
    translate([20, 0, 0])
    circle(r = 3);
}