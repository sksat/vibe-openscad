$fn = 60;

// 基本寸法
leaf_length = 30;     // 縦 (Y軸方向)
leaf_width = 25;      // 横 (開き方向)
leaf_thickness = 2;   // 板厚
knuckle_od = 8;       // ナックル外径
pin_dia = 4;          // ピン軸径
pin_clearance = 0.6;  // 穴径クリアランス (ピン直径4mm + 0.6mm = 4.6mm)
knuckle_id = pin_dia + pin_clearance; 
pin_length = 32;      // ピン全長
knuckle_seg = leaf_length / 5; // ナックル1個の長さ (6mm)

// 皿穴モジュール (表面 z=0 から下向き -Z 方向に穴あけ)
module countersunk_hole() {
    // 皿モミ部 (上面径6mm、深さ1mmのテーパー)
    translate([0, 0, 0.01])
        cylinder(d1 = 6, d2 = 3.2, h = 1.01);
    // 貫通穴部 (下部貫通)
    translate([0, 0, -leaf_thickness - 0.5])
        cylinder(d = 3.2, h = leaf_thickness + 1);
}

// ネジ穴パターンの配置 (板の平坦部)
module screw_holes(x_offset) {
    pitch = 8;
    for (i = [-1, 0, 1]) {
        translate([x_offset, (leaf_length / 2) + (i * pitch), 0])
            countersunk_hole();
    }
}

// 左板 (Left Leaf: ナックルインデックス 0, 2, 4)
module left_leaf() {
    color([0.7, 0.7, 0.75])
    difference() {
        union() {
            // 平板部分 (X < 0 側)
            // Z方向は -leaf_thickness から 0 に配置してナックル上面と滑らかにつなぐ
            translate([-leaf_width, 0, -leaf_thickness])
                cube([leaf_width, leaf_length, leaf_thickness]);

            // ナックル部 (0, 2, 4 番目)
            for (idx = [0, 2, 4]) {
                translate([0, idx * knuckle_seg, 0])
                    rotate([-90, 0, 0])
                        cylinder(d = knuckle_od, h = knuckle_seg);
            }

            // 平板とナックル間の接続補強ブロック
            for (idx = [0, 2, 4]) {
                translate([-knuckle_od / 2, idx * knuckle_seg, -leaf_thickness])
                    cube([knuckle_od / 2, knuckle_seg, leaf_thickness]);
            }
        }
        // ピン穴 (貫通穴)
        translate([0, -1, 0])
            rotate([-90, 0, 0])
                cylinder(d = knuckle_id, h = leaf_length + 2);

        // M3 皿穴 (3個)
        screw_holes(-leaf_width + 8);
    }
}

// 右板 (Right Leaf: ナックルインデックス 1, 3)
module right_leaf() {
    color([0.75, 0.75, 0.8])
    difference() {
        union() {
            // 平板部分 (X > 0 側)
            translate([0, 0, -leaf_thickness])
                cube([leaf_width, leaf_length, leaf_thickness]);

            // ナックル部 (1, 3 番目)
            for (idx = [1, 3]) {
                translate([0, idx * knuckle_seg, 0])
                    rotate([-90, 0, 0])
                        cylinder(d = knuckle_od, h = knuckle_seg);
            }

            // 平板とナックル間の接続補強ブロック
            for (idx = [1, 3]) {
                translate([0, idx * knuckle_seg, -leaf_thickness])
                    cube([knuckle_od / 2, knuckle_seg, leaf_thickness]);
            }
        }
        // ピン穴 (貫通穴)
        translate([0, -1, 0])
            rotate([-90, 0, 0])
                cylinder(d = knuckle_id, h = leaf_length + 2);

        // M3 皿穴 (3個)
        screw_holes(leaf_width - 8);
    }
}

// ピン軸 (Pin)
module pin() {
    color([0.3, 0.3, 0.35])
    translate([0, -(pin_length - leaf_length) / 2, 0])
        rotate([-90, 0, 0])
            cylinder(d = pin_dia, h = pin_length);
}

// 全体アセンブリ
left_leaf();
right_leaf();
pin();