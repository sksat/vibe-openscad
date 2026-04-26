$fn = 100;

// マグカップ本体
difference() {
    // 外形
    cylinder(h = 100, r = 80 / 2);
    
    // 内側をくり抜く
    translate([0, 0, 6])
    cylinder(h = 100 - 6 + 1, r = (80 - 4 * 2) / 2);
}

// 取手
translate([80 / 2 - 2, 0, 100 / 2])
rotate([0, 90, 0])
difference() {
    // 取手の外径
    torus_r = 12;
    rotate_extrude()
    translate([20, 0, 0])
    circle(r = 6);
    
    // 取手をカップにめり込ませて接合部をきれいにするための調整
    translate([-30, 0, 0])
    cube([60, 60, 60], center = true);
}