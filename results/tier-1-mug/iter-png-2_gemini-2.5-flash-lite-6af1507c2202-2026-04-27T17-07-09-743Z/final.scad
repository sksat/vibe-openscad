// マグカップの基本パラメータ
outer_diameter = 80; // 外径 (mm)
height = 100;       // 高さ (mm)
wall_thickness = 4; // 側面肉厚 (mm)
base_thickness = 6; // 底面厚み (mm)

// 内径の計算
inner_diameter = outer_diameter - 2 * wall_thickness;
inner_radius = inner_diameter / 2;
outer_radius = outer_diameter / 2;

// マグカップ本体の作成
module mug_body() {
    difference() {
        // 外側の円筒
        cylinder(h = height, d = outer_diameter, center = false);

        // 内側のくり抜き
        translate([0, 0, base_thickness]) {
            cylinder(h = height - base_thickness, d = inner_diameter, center = false);
        }
    }
}

// 取手のパラメータ
handle_ring_outer_projection = 12; // カップ外壁からの取手のリング外側の飛び出し量
handle_ring_thickness = 4;    // 取手のリングの太さ
handle_finger_hole_diameter = 30; // 指が入るサイズ (内径)
handle_height_center = height / 2; // 取手を付ける中心高さ

// 取手のリングの形状
module handle_ring() {
    // 取手のリングの外側の半径
    handle_ring_outer_radius = outer_radius + handle_ring_outer_projection;

    // 取手のリングの円周方向の中心半径
    handle_ring_center_radius = handle_ring_outer_radius - handle_ring_thickness / 2;

    rotate([90, 0, 0]) { // Z軸周りに90度回転して横向きにする
        translate([handle_ring_center_radius, 0, handle_height_center]) {
            // toroidal shape
            rotate_extrude(convexity = 10) {
                translate([handle_ring_thickness / 2, 0, 0]) {
                    circle(r = handle_ring_thickness / 2, $fn = 64);
                }
            }
        }
    }
}

// 取手の接続部分 (カップ本体と取手のリングを繋ぐ)
module handle_connectors() {
    handle_ring_thickness = 4;
    handle_height_center = height / 2;
    handle_outer_projection = 12; // カップ外壁からの取手のリング外側の飛び出し量

    // 取手のリングの円周方向の中心半径
    handle_ring_center_radius = outer_radius + handle_outer_projection + handle_ring_thickness / 2;

    // 取手の接続部分（カップ本体と取手のリングを繋ぐ）
    // 左側の接続
    hull() {
        // 取手のリングの左端（回転後の位置を考慮）
        translate([-(handle_ring_center_radius), 0, handle_height_center]) {
            sphere(r = handle_ring_thickness, $fn = 32);
        }
        // カップ本体の左側円周上の点
        translate([-outer_radius, 0, handle_height_center]) {
            sphere(r = handle_ring_thickness, $fn = 32);
        }
    }
    // 右側の接続
    hull() {
        // 取手のリングの右端（回転後の位置を考慮）
        translate([handle_ring_center_radius, 0, handle_height_center]) {
            sphere(r = handle_ring_thickness, $fn = 32);
        }
        // カップ本体の右側円周上の点
        translate([outer_radius, 0, handle_height_center]) {
            sphere(r = handle_ring_thickness, $fn = 32);
        }
    }
}

// マグカップ全体を結合
union() {
    mug_body();
    handle_ring();
    handle_connectors();
}