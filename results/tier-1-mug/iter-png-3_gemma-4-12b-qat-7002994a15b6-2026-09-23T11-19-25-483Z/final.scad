$fn = 100; // 滑らかさを向上

// パラメータ
outer_diameter = 80;
height = 100;
wall_thickness = 4;
bottom_thickness = 6;

// 取っ手の設計
// 課題の「外径方向に飛び出す半径 12mm」を厳守します。
// カップの半径は 40mm なので、取手の外側の端は 40 + 12 = 52mm になります。
handle_protrusion = 12; 
// 指を通すための空間を確保するため、取手の肉厚を調整します。
// 取っ手の中心位置を計算：
// 外側の端(52mm) - 取っ手の半径(r) = 中心位置
// 内側の端(40mm + 隙間) + 取っ手の半径(r) = 中心位置
// 隙間を 4mm とすると、取手の半径は (52 - 44) / 2 = 4mm となります。
handle_tube_radius = 4;
handle_major_r = (outer_diameter / 2) + handle_protrusion - handle_tube_radius;

// 内寸の計算
inner_diameter = outer_diameter - (2 * wall_thickness);
inner_height = height - bottom_thickness;

union() {
    // マグカップ本体
    difference() {
        // 外側の円柱
        cylinder(d = outer_diameter, h = height);
        
        // 内側の空間（底面をくり抜く）
        translate([0, 0, bottom_thickness])
            cylinder(d = inner_diameter, h = inner_height + 1);
    }

    // 取っ手 (リング状)
    // rotate_extrude を使用してドーナツ状の形状を作成
    // 中心高さ (height / 2) に配置
    translate([handle_major_r, 0, height / 2])
    rotate([0, 90, 0])
    rotate_extrude()
    translate([handle_tube_radius, 0, 0])
    circle(r = handle_tube_radius);
}