// マグカップのパラメータ
outer_diameter = 80;
outer_radius = outer_diameter / 2;
height = 100;
wall_thickness = 4;
bottom_thickness = 6;
handle_radius = 12;

// マグカップ本体
difference() {
    // 外側の円柱
    cylinder(h = height, r = outer_radius, $fn = 100);
    
    // 内側をくり抜く
    translate([0, 0, bottom_thickness])
        cylinder(h = height - bottom_thickness + 1, r = outer_radius - wall_thickness, $fn = 100);
}

// 取手
translate([outer_radius + handle_radius, 0, height / 2]) {
    rotate([90, 0, 0]) {
        difference() {
            // 外側のトーラス
            rotate_extrude($fn = 100)
                translate([handle_radius * 1.5, 0, 0])
                    circle(r = handle_radius, $fn = 50);
            
            // 内側をくり抜く
            rotate_extrude($fn = 100)
                translate([handle_radius * 1.5, 0, 0])
                    circle(r = handle_radius - wall_thickness, $fn = 50);
        }
    }
}