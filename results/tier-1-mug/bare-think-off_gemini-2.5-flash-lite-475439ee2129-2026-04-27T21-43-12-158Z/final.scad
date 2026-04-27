// マグカップの基本パラメータ
outer_diameter = 80;
height = 100;
wall_thickness = 4;
base_thickness = 6;

// 取手のパラメータ
handle_radius = 12;
handle_thickness = 5;
handle_ring_diameter = 50; // 取手のリング部分の内径

// カップ本体の作成
difference() {
    // 外側の円柱
    cylinder(h = height, d = outer_diameter, $fn = 100);

    // 内側のくり抜き部分
    translate([0, 0, base_thickness]) {
        cylinder(h = height - base_thickness, d = outer_diameter - 2 * wall_thickness, $fn = 100);
    }

    // 底面のくり抜き (内側から少し上にずらして、底面をくり抜かないようにする)
    translate([0, 0, -0.1]) { // わずかに下にずらすことで、底面をくり抜かないようにする
        cylinder(h = base_thickness + 0.1, d = outer_diameter - 2 * wall_thickness, $fn = 100);
    }
}

// 取手の作成
// 取手の中心高さをカップの高さの半分とする
handle_center_height = height / 2;

// 取手をカップの外周に配置
// 外径から壁厚を引いた半径 + 取手のリング半径 の位置に円を配置し、それを押し出してリング状にする
// 取手のリング部分の配置を調整
handle_pos_radius = (outer_diameter - wall_thickness) / 2 + handle_radius * 0.8; // 外周から少し離す
handle_ring_outer_diameter = handle_radius * 2;

// 取手のリング部分
translate([handle_pos_radius, 0, handle_center_height]) {
    rotate([0, 90, 0]) {
        cylinder(h = handle_ring_diameter, d = handle_ring_outer_diameter, $fn = 100);
        translate([0, 0, handle_ring_diameter / 2]) {
            cylinder(h = handle_ring_diameter, d = handle_ring_outer_diameter - 2 * handle_thickness, $fn = 100);
        }
    }
}

// 取手の根元部分 (カップ本体との接続)
// 側面と取手のリング部分を滑らかに繋ぐために、円筒を配置する
// 側面から外側に向かって伸びるように
handle_connection_radius = (outer_diameter - wall_thickness) / 2;
handle_connection_height = handle_thickness * 2; // 根元の接続部分の高さ

translate([handle_connection_radius, 0, handle_center_height - handle_connection_height/2]) {
    rotate([0, 90, 0]) {
        cylinder(h = handle_connection_height, d = handle_thickness*2, $fn=100);
    }
}

// 反対側の取手の根元部分
translate([handle_connection_radius, 0, handle_center_height + handle_connection_height/2]) {
    rotate([0, 90, 0]) {
        cylinder(h = handle_connection_height, d = handle_thickness*2, $fn=100);
    }
}

// 取手のリング部分の反対側
translate([-handle_pos_radius, 0, handle_center_height]) {
    rotate([0, 90, 0]) {
        cylinder(h = handle_ring_diameter, d = handle_ring_outer_diameter, $fn = 100);
        translate([0, 0, handle_ring_diameter / 2]) {
            cylinder(h = handle_ring_diameter, d = handle_ring_outer_diameter - 2 * handle_thickness, $fn = 100);
        }
    }
}

// 取手の根元部分 (反対側)
translate([-handle_connection_radius, 0, handle_center_height - handle_connection_height/2]) {
    rotate([0, 90, 0]) {
        cylinder(h = handle_connection_height, d = handle_thickness*2, $fn=100);
    }
}

translate([-handle_connection_radius, 0, handle_center_height + handle_connection_height/2]) {
    rotate([0, 90, 0]) {
        cylinder(h = handle_connection_height, d = handle_thickness*2, $fn=100);
    }
}