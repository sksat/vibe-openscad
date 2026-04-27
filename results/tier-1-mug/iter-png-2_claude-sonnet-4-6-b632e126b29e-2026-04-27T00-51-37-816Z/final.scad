// マグカップ
// 外径: 80mm, 高さ: 100mm, 肉厚: 4mm, 底厚: 6mm

$fn = 128;

// パラメータ
outer_radius = 40;               // 外径80mm → 半径40mm
cup_height   = 100;              // 高さ
wall         = 4;                // 肉厚
bottom       = 6;                // 底面の厚み
inner_radius = outer_radius - wall;  // 内径半径 = 36mm

// 取手パラメータ
handle_tube_r = 5;               // 取手チューブ断面の半径
handle_ring_r = 18;              // 取手リング中心の半径（指を通せる穴のサイズに影響）
handle_z      = cup_height / 2; // 取手中心高さ（カップ中央）

// 取手リング中心のX位置：カップ外周面 + リング半径
// これによりリングがカップ外周から突き出す
handle_cx = outer_radius + handle_ring_r;

module cup_body() {
    difference() {
        // カップ外側
        cylinder(h = cup_height, r = outer_radius);
        // 内側をくり抜く（底はbottom分残す）
        translate([0, 0, bottom])
            cylinder(h = cup_height - bottom + 1, r = inner_radius);
    }
}

module handle() {
    // トーラス状取手
    // rotate_extrudeはZ軸周りに回転するため、XZ平面上に断面を置く
    translate([handle_cx, 0, handle_z])
        rotate([90, 0, 0])
            rotate_extrude(angle = 360, $fn = 128)
                translate([handle_ring_r, 0, 0])
                    circle(r = handle_tube_r, $fn = 64);
}

union() {
    cup_body();
    handle();
}