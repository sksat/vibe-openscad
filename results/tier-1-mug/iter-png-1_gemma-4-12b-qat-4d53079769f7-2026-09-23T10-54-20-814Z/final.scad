$fn = 64;

// パラメータ
outer_diameter = 80;
height = 100;
wall_thickness = 4;
bottom_thickness = 6;
handle_protrusion = 12; // 外径方向への飛び出し量 (40mm + 12mm = 52mmの位置まで)

// 内寸の計算
inner_diameter = outer_diameter - (2 * wall_thickness);
inner_height = height - bottom_thickness;

// 取っ手の計算
// 「指を通せる」ためには、カップの表面と取手の内側に隙間が必要です。
// カップの半径 = 40mm
// 取っ手の太さを直径10mm（半径5mm）と設定。
// 取っ手の内側の端をカップ表面から2mm離した位置（42mm）に配置。
handle_thickness = 10;
handle_radius = handle_thickness / 2;
handle_major_r = (outer_diameter / 2) + handle_protrusion - handle_radius;
// 上記の計算で handle_major_r = 40 + 12 - 5 = 47mm となり、
// 取っ手の内側は 47 - 5 = 42mm（カップから2mm離れた位置）にきます。

// 形状の構築
union() {
    // マグカップ本体
    difference() {
        // 外側の円柱
        cylinder(d = outer_diameter, h = height);
        
        // 内側の空間
        translate([0, 0, bottom_thickness])
            cylinder(d = inner_diameter, h = inner_height + 1);
    }

    // 取っ手 (リング状・ループ状)
    // 中心高さに配置
    translate([handle_major_r, 0, height / 2])
    rotate([0, 90, 0])
    rotate_extrude()
    translate([handle_radius, 0, 0])
    circle(r = handle_radius);
}