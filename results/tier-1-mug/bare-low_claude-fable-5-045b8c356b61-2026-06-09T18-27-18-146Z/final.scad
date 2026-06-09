// マグカップ
// 外径 80mm (半径 40mm)、高さ 100mm、肉厚 4mm、底厚 6mm
// 半径 12mm のリング状取手付き

$fn = 100;

cup_outer_r = 40;   // 外半径
cup_h       = 100;  // 高さ
wall_t      = 4;    // 肉厚
bottom_t    = 6;    // 底厚

handle_r      = 12; // 取手リングの半径(中心円)
handle_tube_r = 5;  // 取手の太さ(断面半径)

union() {
    // カップ本体(くり抜き)
    difference() {
        cylinder(h = cup_h, r = cup_outer_r);
        translate([0, 0, bottom_t])
            cylinder(h = cup_h - bottom_t + 1, r = cup_outer_r - wall_t);
    }

    // 取手(トーラス)を側面の中心高さに取り付け
    translate([cup_outer_r + handle_r - 2, 0, cup_h / 2])
        rotate([90, 0, 0])
            rotate_extrude(angle = 360)
                translate([handle_r, 0, 0])
                    circle(r = handle_tube_r);
}