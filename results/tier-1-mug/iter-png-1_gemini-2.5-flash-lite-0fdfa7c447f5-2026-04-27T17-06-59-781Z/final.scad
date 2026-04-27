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
handle_radius_from_wall = 12; // カップ外壁からの取手のリング外側の飛び出し量
handle_ring_thickness = 4;    // 取手のリングの太さ
handle_ring_diameter_inner = 30; // 指が入るサイズ (内径)
handle_height_center = height / 2; // 取手を付ける中心高さ

// 取手のリングの形状
module handle_ring() {
    // 取手のリングの外側の半径
    handle_ring_outer_radius = outer_radius + handle_radius_from_wall;

    rotate([90, 0, 0]) {
        translate([0, 0, handle_height_center]) {
            difference() {
                // 外側のリング
                minkowski() {
                    cylinder(h = handle_ring_thickness, d = handle_ring_diameter_inner + 2 * handle_ring_thickness, center = true);
                    sphere(r = handle_ring_thickness / 2, $fn = 32);
                }
                // 内側のくり抜き
                cylinder(h = handle_ring_thickness, d = handle_ring_diameter_inner, center = true);
            }
        }
    }
}

// 取手の接続部分 (カップ本体と取手のリングを繋ぐ)
module handle_connectors() {
    handle_ring_thickness = 4;
    handle_height_center = height / 2;
    handle_outer_offset = 12; // カップ外壁からの取手のリング外側の飛び出し量

    // 取手のリングの円周方向の中心半径
    // 取手のリングの外側がカップ外壁から handle_outer_offset だけ飛び出すように計算
    handle_ring_center_radius = outer_radius + handle_outer_offset + handle_ring_thickness;

    // 取手の接続部分（カップ本体と取手のリングを繋ぐ）
    hull() {
        // 取手のリングの左端
        translate([-(handle_ring_center_radius), 0, handle_height_center]) {
            sphere(r = handle_ring_thickness, $fn = 32);
        }
        // カップ本体の左側円周上の点
        translate([-outer_radius, 0, handle_height_center]) {
            sphere(r = handle_ring_thickness, $fn = 32);
        }
    }
    hull() {
        // 取手のリングの右端
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