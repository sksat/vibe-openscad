// Parameters
leaf_w = 25;
leaf_h = 30;
leaf_t = 2;
knuckle_od = 8;
knuckle_id = 4.3;
pin_d = 4;
pin_l = 32;
knuckle_segment = 6;
hole_pitch = 8;

$fn = 100;

module leaf_part(is_left) {
    difference() {
        union() {
            // 板部分: Knuckle中心高さ(4mm)と合わせるためにZを調整
            translate([is_left ? -(leaf_w + knuckle_od/2) : knuckle_od/2, -leaf_h / 2, (knuckle_od - leaf_t)/2]) 
                cube([leaf_w, leaf_h, leaf_t]);
            
            // Knuckle部分
            for (i = [0, 1, 2, 3, 4]) {
                if ((is_left && (i == 0 || i == 2 || i == 4)) || 
                    (!is_left && (i == 1 || i == 3))) {
                    translate([0, -leaf_h / 2 + i * knuckle_segment, knuckle_od/2])
                    rotate([-90, 0, 0])
                    cylinder(d = knuckle_od, h = knuckle_segment);
                }
            }
        }
        // ピン軸用の貫通穴
        translate([0, -leaf_h / 2, knuckle_od/2]) 
            rotate([-90, 0, 0]) 
            cylinder(d = knuckle_id, h = leaf_h);
        
        // 皿穴と貫通穴 (上面がZ=knuckle_od/2 + leaf_t/2になるよう配置)
        surface_z = (knuckle_od + leaf_t) / 2;
        for (i = [-1, 0, 1]) {
            translate([is_left ? -(leaf_w/2 + knuckle_od/2) : (leaf_w/2 + knuckle_od/2), i * hole_pitch, surface_z - leaf_t]) {
                cylinder(d = 3.2, h = leaf_t); // 貫通穴
                translate([0, 0, leaf_t - 1]) 
                    cylinder(d1 = 3.2, d2 = 6, h = 1.1); // 皿穴
            }
        }
    }
}

// 組み立て
leaf_part(true);  // 左板
leaf_part(false); // 右板

// ピン軸
color("silver")
translate([0, -16, knuckle_od/2]) 
    rotate([-90, 0, 0]) 
    cylinder(d = pin_d, h = pin_l);