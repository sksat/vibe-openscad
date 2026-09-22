$fn = 64;

// パラメータ
outer_diameter = 80;
height = 100;
wall_thickness = 4;
bottom_thickness = 6;
handle_protrusion = 12; // 外径方向への飛び出し量
handle_ring_thickness = 12; // 取手の太さ（直径）

// 内寸の計算
inner_diameter = outer_diameter - (2 * wall_thickness);
inner_height = height - bottom_thickness;

// 取っ手の計算
// 取っ手の外側の端が「外径 + 飛び出し量」になるように配置
// 外径半径 = 40mm, 飛び出し = 12mm => 外端 = 52mm
// 取っ手半径 = 6mm (直径12mm)
// 取っ手の中心半径 = 52 - 6 = 46mm
handle_r = handle_ring_thickness / 2;
handle_major_r = (outer_diameter / 2) + handle_protrusion - handle_r;

// 形状の構築
union() {
    // マグカップ本体
    difference() {
        // 外側の円柱
        cylinder(d = outer_diameter, h = height);
        
        // 内側の空間（底面を考慮して上にオフセット）
        translate([0, 0, bottom_thickness])
            cylinder(d = inner_diameter, h = inner_height + 1);
    }

    // 取っ手 (リング状)
    translate([handle_major_r, 0, height / 2])
    rotate([0, 90, 0])
    rotate_extrude()
    translate([handle_r, 0, 0])
    circle(r = handle_r);
}