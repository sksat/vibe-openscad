$fn = 50;

// カップ本体
difference() {
    cylinder(d=80, h=100);
    translate([0, 0, 6])
        cylinder(d=72, h=95);
}

// 取手
translate([40, 0, 50])
rotate([0, 90, 0])
rotate_extrude()
translate([20, 0, 0])
circle(r=6);