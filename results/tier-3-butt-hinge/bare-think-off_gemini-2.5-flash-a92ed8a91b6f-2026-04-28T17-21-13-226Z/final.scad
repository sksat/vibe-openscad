// 家具用小型バット蝶番

// 全体の寸法
leaf_width = 25;       // 板の幅 (ヒンジ軸から外側へ)
leaf_length = 30;      // 板の長さ (ヒンジ軸方向)
leaf_thickness = 2;    // 板の厚さ

pin_diameter = 4;      // ピン軸の直径
pin_length = 32;       // ピン軸の長さ

knuckle_outer_diameter = 8;  // knuckle の外径
knuckle_inner_diameter = pin_diameter + 0.3; // knuckle の内径 (クリアランス含む)
knuckle_length = leaf_length / 5; // 各 knuckle の長さ

// 皿穴の寸法
screw_hole_diameter = 3.2;    // 皿穴の貫通部直径
screw_head_diameter = 6;      // 皿頭の最大直径
screw_head_depth = 1;         // 皿頭の深さ
screw_pitch_y = 8;            // 皿穴のY方向ピッチ

// ピン軸
module pin() {
    cylinder(h = pin_length, d = pin_diameter, center = true);
}

// knuckle (筒部)
module knuckle() {
    cylinder(h = knuckle_length, d = knuckle_outer_diameter, center = true);
    cylinder(h = knuckle_length + 0.1, d = knuckle_inner_diameter, center = true); // 貫通穴
}

// 皿穴
module countersunk_hole() {
    cylinder(h = leaf_thickness + 0.1, d = screw_hole_diameter, center = true);
    cylinder(h = screw_head_depth, d1 = screw_head_diameter, d2 = screw_hole_diameter, center = true);
}

// 板モジュール
module leaf(is_left) {
    difference() {
        // 基本の板形状
        cube([leaf_width, leaf_length, leaf_thickness], center = true);

        // knuckle のための切り欠きと穴
        for (i = [0:4]) {
            if ((is_left && (i == 0 || i == 2 || i == 4)) || (!is_left && (i == 1 || i == 3))) {
                translate([
                    leaf_width/2 - knuckle_outer_diameter/2,
                    (i - 2) * knuckle_length - knuckle_length/2, // Y軸方向配置
                    0
                ]) {
                    cylinder(h = leaf_thickness + 0.1, d = knuckle_outer_diameter, center = true);
                }
            } else {
                 translate([
                    leaf_width/2 - knuckle_inner_diameter/2, // 切り欠き位置 (ピン軸の中心)
                    (i - 2) * knuckle_length - knuckle_length/2, // Y軸方向配置
                    0
                 ]) {
                     cylinder(h = leaf_thickness + 0.1, d = knuckle_inner_diameter, center = true);
                 }
            }
        }
    }

    // 皿穴
    for (i = [-1, 0, 1]) {
        translate([
            -leaf_width / 2 + screw_head_diameter / 2 + 3, // 板の端から少し内側
            i * screw_pitch_y,
            -leaf_thickness / 2
        ]) {
            countersunk_hole();
        }
    }
}

// 左板 (knuckle 1, 3, 5番目)
module left_leaf_assembly() {
    translate([-(leaf_width + knuckle_outer_diameter)/2, 0, 0]) {
        leaf(true);
    }
    // knuckle を配置
    for (i = [0, 2, 4]) {
        translate([
            -knuckle_outer_diameter/2, // ピン軸の中心X座標
            (i - 2) * knuckle_length, // Y軸方向配置
            0
        ]) {
            knuckle();
        }
    }
}

// 右板 (knuckle 2, 4番目)
module right_leaf_assembly() {
    translate([(leaf_width + knuckle_outer_diameter)/2, 0, 0]) {
        leaf(false);
    }
    // knuckle を配置
    for (i = [1, 3]) {
        translate([
            knuckle_outer_diameter/2, // ピン軸の中心X座標
            (i - 2) * knuckle_length, // Y軸方向配置
            0
        ]) {
            knuckle();
        }
    }
}

// 最終アセンブリ
union() {
    // ピン軸 (Y軸に沿う)
    translate([0, 0, 0]) {
        pin();
    }

    // 左板とknuckle群
    translate([0, 0, -leaf_thickness / 2]) { // Z軸方向に半分ずらす
        left_leaf_assembly();
    }

    // 右板とknuckle群 (180度開いた状態)
    translate([0, 0, -leaf_thickness / 2]) { // Z軸方向に半分ずらす
        right_leaf_assembly();
    }
}