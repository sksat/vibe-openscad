// マグカップの設計パラメータ
mug_outer_radius = 40;
mug_inner_radius = 35;
mug_height = 90;
mug_bottom_thickness = 6;

handle_outer_radius = 35;
handle_inner_width = 25;
handle_inner_height = 30;
handle_thickness = 10; // D字の厚み（内側の空間に対する肉厚）

$fn = 100;

// 本体
difference() {
    // 外側の円筒
    cylinder(h = mug_height, r = mug_outer_radius);
    
    // 内側の空洞（底面の厚みを考慮して上方向にずらす）
    translate([0, 0, mug_bottom_thickness])
        cylinder(h = mug_height, r = mug_inner_radius);
}

// 取っ手 (Handle)
union() {
    difference() {
        // 取っ手の外形 (D字形状)
        // x=39.5の位置で中心を置くことで、半径40のマグ本体とわずかに重なり(0.5mm)を確保しマニフォールドを維持
        difference() {
            rotate([0, 90])
            translate([39.5, 0, mug_height / 2])
            cylinder(h = handle_outer_radius * 2, r = handle_outer_radius, center = true);
            
            // x < 39.5 の部分を削り取り、x > 39.5 の側（+X方向）のみを残す
            translate([-100, -100, -100])
            cube([39.5, 100, 100]);
        }
        
        // 取っ手の内側の空間 (指が入る穴)
        // 取っ手は x=39.5 から始まり、幅25mmなので x=64.5 まで
        translate([39.5, 0, mug_height / 2])
        cube([handle_inner_width, handle_thickness, handle_inner_height]);
    }
}