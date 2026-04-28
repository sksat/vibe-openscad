/*
  家具用小型バット蝶番 (Butt Hinge)
  - 板サイズ: 30mm(H) x 25mm(W) x 2mm(T)
  - ピン: φ4mm x 32mm
  - ナックル: 外径8mm, 5分割
*/

$fn = 100;

// --- パラメータ ---
leaf_h = 30;          // 縦
leaf_w = 25;          // 横幅
leaf_t = 2;           // 厚み
pin_d = 4;            // ピン径
pin_l = 32;           // ピン長さ
knuckle_od = 8;       // ナックル外径
knuckle_id = 4.6;     // ナックル内径(クリアランス込)
segments = 5;         // ナックル分割数
seg_h = leaf_h / segments; // 6mm

screw_d = 3.2;        // M3貫通穴
screw_head_d = 6;     // 皿穴径
screw_head_t = 1;     // 皿穴深さ
hole_pitch = 8;       // 穴ピッチ
hole_x_offset = 17;   // ピン中心から穴までの距離

// --- 皿穴モジュール ---
module countersink_hole() {
    // 貫通穴
    translate([0, 0, -leaf_t - 1])
        cylinder(d = screw_d, h = leaf_t + 2);
    // 皿取り部 (表面Z=0から下へ)
    translate([0, 0, -screw_head_t])
        cylinder(d1 = screw_d, d2 = screw_head_d, h = screw_head_t + 0.01);
}

// --- ナックル単体モジュール ---
module knuckle_seg(y_pos) {
    translate([0, y_pos, 0])
    rotate([-90, 0, 0])
    difference() {
        cylinder(d = knuckle_od, h = seg_h);
        translate([0, 0, -0.5])
            cylinder(d = knuckle_id, h = seg_h + 1);
    }
}

// --- 左板 (Left Leaf: 3ナックル) ---
color("silver")
difference() {
    union() {
        // 板本体: X=0(中心)から左へ25mm。厚み方向は上面をZ=0に
        translate([-leaf_w, 0, -leaf_t])
            cube([leaf_w, leaf_h, leaf_t]);
        // ナックル (1, 3, 5番目)
        for (i = [0, 2, 4]) {
            knuckle_seg(i * seg_h);
        }
    }
    // ピン穴の逃げ（念のため中央を再カット）
    rotate([-90, 0, 0]) translate([0, 0, -1])
        cylinder(d = knuckle_id, h = leaf_h + 2);
    
    // 皿穴 3つ
    for (i = [0:2]) {
        y = (leaf_h - (2 * hole_pitch)) / 2 + i * hole_pitch;
        translate([-hole_x_offset, y, 0])
            countersink_hole();
    }
}

// --- 右板 (Right Leaf: 2ナックル) ---
color("lightgray")
difference() {
    union() {
        // 板本体: X=0から右へ25mm
        translate([0, 0, -leaf_t])
            cube([leaf_w, leaf_h, leaf_t]);
        // ナックル (2, 4番目)
        for (i = [1, 3]) {
            knuckle_seg(i * seg_h);
        }
    }
    // ピン穴の逃げ
    rotate([-90, 0, 0]) translate([0, 0, -1])
        cylinder(d = knuckle_id, h = leaf_h + 2);

    // 皿穴 3つ
    for (i = [0:2]) {
        y = (leaf_h - (2 * hole_pitch)) / 2 + i * hole_pitch;
        translate([hole_x_offset, y, 0])
            countersink_hole();
    }
}

// --- ピン軸 (Pin) ---
color("dimgray")
translate([0, (leaf_h - pin_l) / 2, 0]) // 30mm高に対して32mm長を中央配置
rotate([-90, 0, 0])
cylinder(d = pin_d, h = pin_l);