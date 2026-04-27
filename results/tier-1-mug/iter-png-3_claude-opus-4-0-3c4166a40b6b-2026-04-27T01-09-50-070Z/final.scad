// マグカップのパラメータ
outer_diameter = 80;
outer_radius = outer_diameter / 2;
height = 100;
wall_thickness = 4;
bottom_thickness = 6;
handle_thickness = 8;
handle_outer_radius = 20;
handle_inner_radius = 12;

// マグカップ本体
difference() {
    // 外側の円柱
    cylinder(h = height, r = outer_radius, $fn = 100);
    
    // 内側をくり抜く
    translate([0, 0, bottom_thickness])
        cylinder(h = height - bottom_thickness + 1, r = outer_radius - wall_thickness, $fn = 100);
}

// 取手
translate([outer_radius, 0, height / 2])
    rotate([90, 0, 0])
        difference() {
            // 取手の外側
            cylinder(h = handle_thickness, r = handle_outer_radius, center = true, $fn = 100);
            
            // 取手の内側（指を通す穴）
            cylinder(h = handle_thickness + 1, r = handle_inner_radius, center = true, $fn = 100);
            
            // カップ本体と重なる部分を切り取る
            translate([-handle_outer_radius - outer_radius, 0, 0])
                cube([handle_outer_radius * 2, handle_thickness + 2, handle_outer_radius * 2 + 2], center = true);
        }