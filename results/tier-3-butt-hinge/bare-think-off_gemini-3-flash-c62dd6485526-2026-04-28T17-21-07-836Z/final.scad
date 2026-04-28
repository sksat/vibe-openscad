// 家具用小型バット蝶番 (Butt Hinge)
$fn = 64;

// パラメータ
leaf_w = 25;      // 板の幅
leaf_h = 30;      // 板の高さ
leaf_t = 2;       // 板の厚み
knuckle_od = 8;   // ナックル外径
pin_d = 4;        // ピン直径
clearance = 0.3;  // ピン穴のクリアランス
knuckle_h = leaf_h / 5; // ナックル1個の高さ (6mm)

pin_len = 32;     // ピンの長さ

// ピン軸
module pin() {
    color("Silver")
    translate([0, -1, 0])
    rotate([-90, 0, 0])
    cylinder(d = pin_d, h = pin_len);
}

// 皿穴 (M3用)
module screw_hole() {
    // 貫通穴
    cylinder(d = 3.2, h = leaf_t * 3, center = true);
    // 皿部分 (表面 Z=leaf_t/2 から下へ)
    translate([0, 0, leaf_t/2 - 1])
    cylinder(d1 = 3.2, d2 = 6, h = 1.01);
}

// 板とナックルの基本形状
module leaf_part(is_left = true) {
    knuckle_indices = is_left ? [0, 2, 4] : [1, 3];
    
    difference() {
        union() {
            // 板部分
            if (is_left) {
                translate([-leaf_w, 0, -leaf_t/2])
                cube([leaf_w, leaf_h, leaf_t]);
            } else {
                translate([0, 0, -leaf_t/2])
                cube([leaf_w, leaf_h, leaf_t]);
            }
            
            // ナックル部分
            for (i = knuckle_indices) {
                translate([0, i * knuckle_h, 0])
                rotate([-90, 0, 0])
                cylinder(d = knuckle_od, h = knuckle_h);
            }
        }
        
        // ピン穴
        rotate([-90, 0, 0])
        translate([0, 0, -1])
        cylinder(d = pin_d + clearance, h = leaf_h + 2);
        
        // 皿穴の配置 (ナックルから離れた側)
        hole_x = is_left ? -leaf_w + 6 : leaf_w - 6;
        for (y_offset = [-8, 0, 8]) {
            translate([hole_x, leaf_h/2 + y_offset, 0])
            screw_hole();
        }
    }
}

// 組み立て
union() {
    // 左板
    color("LightGrey")
    leaf_part(is_left = true);
    
    // 右板
    color("DarkGray")
    leaf_part(is_left = false);
    
    // ピン
    pin();
}