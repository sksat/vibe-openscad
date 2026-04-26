// マグカップの寸法
outer_diameter = 80;
height = 100;
wall_thickness = 4;
bottom_thickness = 6;

// 取手の寸法
handle_radius = 12;
handle_diameter = 2 * handle_radius;
handle_thickness = 6; // 取手のリング自体の太さ

// 内径の計算
inner_diameter = outer_diameter - 2 * wall_thickness;
inner_radius = inner_diameter / 2;
outer_radius = outer_diameter / 2;

// マグカップ本体の作成
difference() {
    // 外側の円筒
    cylinder(h = height, d = outer_diameter, $fn = 100);

    // 内側のくり抜き部分 (飲み物が入る部分)
    translate([0, 0, bottom_thickness]) {
        cylinder(h = height - bottom_thickness, d = inner_diameter, $fn = 100);
    }
}

// 取手の作成
// 取手の中心位置 (カップの中心高さ)
handle_center_z = height / 2;

// 取手のリング形状を作成
// 外側のリング
difference() {
    // 取手外側の円筒
    cylinder(h = handle_thickness, r = outer_radius + handle_radius, $fn = 100);
    // 取手内側のくり抜き円筒
    translate([0, 0, -0.1]) { // 少し下にずらして確実にくり抜く
        cylinder(h = handle_thickness + 0.2, r = outer_radius, $fn = 100);
    }
}

// 取手をカップ本体に結合させるための形状
// 取手全体を覆う形状で、カップ本体と重複させる
union() {
    // 取手部分をカップ本体に結合するための円筒 (カップの外側円筒と同じ位置・高さ)
    translate([0, 0, height - handle_thickness]) {
        cylinder(h = handle_thickness, d = outer_diameter, $fn = 100);
    }
    // 取手部分をカップ本体に結合するための円筒 (カップの内側円筒と同じ位置・高さ)
    translate([0, 0, bottom_thickness]) {
        cylinder(h = height - bottom_thickness, d = inner_diameter, $fn = 100);
    }
}

// 取手をカップ本体に移動・回転させて配置
// 取手はカップの外周から radialy に飛び出すように配置
// 取手の中心をカップの中心高さに合わせる
// 取手のリングをカップの外周に沿わせるように配置

// 外径方向に飛び出す取手部分
handle_part_outer_radius = outer_radius + handle_radius;
handle_part_inner_radius = outer_radius;

// 取手のリング部分の円筒を作成
handle_ring_cyl = cylinder(h = handle_thickness, r1 = handle_part_outer_radius, r2 = handle_part_outer_radius, $fn = 100);
handle_ring_inner_cyl = cylinder(h = handle_thickness, r1 = handle_part_inner_radius, r2 = handle_part_inner_radius, $fn = 100);

// 取手リングの形状 (ドーナツ状)
handle_ring_shape = difference() {
    handle_ring_cyl;
    translate([0, 0, -0.1]) { // 少し下にずらして確実にくり抜く
        cylinder(h = handle_thickness + 0.2, r = handle_part_inner_radius, $fn = 100);
    }
}

// 取手をカップ本体に結合させるための形状
// 取手のリングをカップ本体と結合させる
union() {
    // 取手のリングをカップ本体の側面に結合させる
    // 取手のリングをカップの中心高さに配置
    translate([0, 0, handle_center_z - handle_thickness / 2]) {
        rotate([90, 0, 0]) {
            handle_ring_shape;
        }
    }
}

// 最終的なマグカップの形状
union() {
    // マグカップ本体
    difference() {
        cylinder(h = height, d = outer_diameter, $fn = 100);
        translate([0, 0, bottom_thickness]) {
            cylinder(h = height - bottom_thickness, d = inner_diameter, $fn = 100);
        }
    }

    // 取手
    translate([0, 0, handle_center_z - handle_thickness / 2]) {
        rotate([90, 0, 0]) {
            difference() {
                cylinder(h = handle_thickness, r = outer_radius + handle_radius, $fn = 100);
                translate([0, 0, -0.1]) {
                    cylinder(h = handle_thickness + 0.2, r = outer_radius, $fn = 100);
                }
            }
        }
    }
}