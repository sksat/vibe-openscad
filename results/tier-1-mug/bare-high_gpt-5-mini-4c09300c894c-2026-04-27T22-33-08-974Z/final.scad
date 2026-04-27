// マグカップ (外径 80mm, 高さ 100mm, 肉厚 4mm, 底面厚 6mm)
// リング状取手 (チューブ半径 12mm)、カップ中央高さに配置

// パラメータ
outer_d = 80;
outer_r = outer_d / 2;
height = 100;
wall_thickness = 4;
bottom_thickness = 6;
inner_r = outer_r - wall_thickness;

handle_tube_r = 12;          // 取手の断面半径（指定の 12mm）
handle_overlap = 2;          // カップとの重なり (mm) - 接合のためわずかに重ねる
handle_center_r = outer_r + handle_tube_r - handle_overlap;
handle_angle = 180;          // 取手のアーク角度（度）
handle_z = height / 2;       // 取手の中心高さ（カップ中心）

$fn = 128; // 解像度

module cup_body() {
    difference() {
        // 外側本体
        cylinder(h = height, r = outer_r, center = false);
        // 内側をくり抜く（底面厚を残す）
        translate([0,0,bottom_thickness])
            cylinder(h = height - bottom_thickness, r = inner_r, center = false);
    }
}

module ring_handle() {
    // 2D の円を回転してトーラス状のアークを作成（高さは 2D の y 座標で指定）
    rotate_extrude(angle = handle_angle)
        translate([handle_center_r, handle_z])
            circle(r = handle_tube_r);
}

union() {
    cup_body();
    ring_handle();
}