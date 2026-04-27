// マグカップ
// 外径: 80mm, 高さ: 100mm, 肉厚: 4mm, 底厚: 6mm

$fn = 128;

// パラメータ
outer_radius = 40;
cup_height   = 100;
wall         = 4;
bottom       = 6;
inner_radius = outer_radius - wall;

// 取手パラメータ
handle_tube_r = 6;               // 取手チューブ断面の半径
handle_ring_r = 18;              // 取手リングの巻き半径（指穴サイズに影響）
handle_z      = cup_height / 2; // 取手中心高さ

// 取手リング中心X: カップ外周面にチューブ外周が接するように
// リング中心 = outer_radius + handle_tube_r + handle_ring_r は離れすぎ
// → カップ外周面からhandle_ring_r離れた位置にリング中心を置き、
//   チューブがカップ外周面に接触・めり込む形にする
handle_cx = outer_radius + handle_ring_r;

module cup_body() {
    difference() {
        cylinder(h = cup_height, r = outer_radius);
        translate([0, 0, bottom])
            cylinder(h = cup_height - bottom + 1, r = inner_radius);
    }
}

module handle_torus() {
    // トーラス: XY平面上のリングをhandle_zに配置
    translate([handle_cx, 0, handle_z])
        rotate([90, 0, 0])
            rotate_extrude(angle = 360, $fn = 128)
                translate([handle_ring_r, 0, 0])
                    circle(r = handle_tube_r, $fn = 64);
}

module handle_connector() {
    // カップ側面と取手トーラスをつなぐ補完ブリッジ
    // カップ外周上の接続点からトーラス最近点までhullで埋める
    hull() {
        // カップ外周面上の小さな球（上下2点）
        translate([outer_radius, 0, handle_z + handle_ring_r * 0.5])
            sphere(r = handle_tube_r, $fn = 64);
        translate([outer_radius, 0, handle_z - handle_ring_r * 0.5])
            sphere(r = handle_tube_r, $fn = 64);
        // トーラスのカップ側最近点（リング内側）
        translate([handle_cx - handle_ring_r, 0, handle_z + handle_ring_r * 0.5])
            sphere(r = handle_tube_r, $fn = 64);
        translate([handle_cx - handle_ring_r, 0, handle_z - handle_ring_r * 0.5])
            sphere(r = handle_tube_r, $fn = 64);
    }
}

union() {
    cup_body();
    handle_torus();
    handle_connector();
}