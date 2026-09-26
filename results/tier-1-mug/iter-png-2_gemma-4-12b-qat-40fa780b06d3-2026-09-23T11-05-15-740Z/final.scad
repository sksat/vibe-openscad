$fn = 100; // 滑らかさを向上

// パラメータ
outer_diameter = 80;
height = 100;
wall_thickness = 4;
bottom_thickness = 6;

// 取っ手の設計
// 「指を通せる」ためには、取手の内側の空洞が十分に必要です。
// 外径半径 40mm に対し、外径方向への飛び出しを 12mm とすると、
// 外側の端は 52mm になります。
// 内側の端をカップ表面から少し離した 42mm に設定すると、
// 取っ手の太さ（厚み）は 10mm となります。
// しかし、これでは指を通すための「空洞」が小さすぎるため、
// 実用性を考慮し、取手の外側への飛び出しを少し調整（または内側の空洞を確保）します。
handle_protrusion = 15; // 12mmより少し大きくして実用性を確保
inner_clearance = 2;    // カップ表面からの隙間

// 取っ手の計算
cup_radius = outer_diameter / 2;
handle_inner_r = cup_radius + inner_clearance; // 42mm
handle_outer_r = cup_radius + handle_protrusion; // 55mm
handle_major_r = (handle_inner_r + handle_outer_r) / 2; // 中心位置 (48.5mm)
handle_tube_r = (handle_outer_r - handle_inner_r) / 2; // 取っ手の太さ (6.5mm)

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
    // rotate_extrude を使ってドーナツ状の形状を作成
    translate([handle_major_r, 0, height / 2])
    rotate([0, 90, 0])
    rotate_extrude()
    translate([handle_tube_r, 0, 0])
    circle(r = handle_tube_r);
}