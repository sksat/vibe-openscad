// マグカップ
// 外径 80mm / 高さ 100mm / 肉厚 4mm / 底厚 6mm
// 取手: リング状 (トーラス), 中心半径 12mm

$fn = 120;

outer_d    = 80;      // 外径
outer_r    = outer_d / 2;
height     = 100;     // 全高
wall       = 4;       // 側面肉厚
bottom     = 6;       // 底厚
inner_r    = outer_r - wall;

handle_R   = 12;      // 取手リングの中心半径
handle_r   = 5;       // 取手の太さ(断面半径)
handle_z   = height / 2;              // 取手の高さ(カップ中心高さ)
handle_x   = outer_r + handle_R * 0.35; // 外周から十分はみ出す位置

module cup_body() {
    difference() {
        cylinder(h = height, r = outer_r);
        translate([0, 0, bottom])
            cylinder(h = height - bottom + 1, r = inner_r);
    }
}

module handle_ring() {
    // YZ 平面に立つトーラス(指を通せる向き)
    translate([handle_x, 0, handle_z])
        rotate([0, 90, 0])
            rotate_extrude(convexity = 10)
                translate([handle_R, 0, 0])
                    circle(r = handle_r);
}

module mug() {
    union() {
        cup_body();
        // 取手はカップ内部に貫通させない
        difference() {
            handle_ring();
            translate([0, 0, -1])
                cylinder(h = height + 2, r = inner_r);
        }
    }
}

mug();