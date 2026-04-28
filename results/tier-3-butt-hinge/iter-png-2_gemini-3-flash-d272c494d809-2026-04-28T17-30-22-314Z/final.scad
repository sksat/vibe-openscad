/*
  家具用小型バット蝶番 (Butt Hinge) - 完成版
  寸法: 板 30x25x2mm, ピン φ4x32mm, ナックル φ8mm (5分割)
*/

$fn = 100;

// --- パラメータ設定 ---
leaf_h = 30;          // 縦（ヒンジ軸方向）
leaf_w = 25;          // 横（展開方向）
leaf_t = 2;           // 板厚
pin_d = 4;            // ピンの直径
pin_l = 32;           // ピンの全長
knuckle_od = 8;       // ナックルの外径
knuckle_id = 4.6;     // ナックルの内径（ピン4mm + クリアランス0.3mmx2）
segments = 5;         // ナックルの分割数
seg_h = leaf_h / segments; // 1区画あたりの高さ (6mm)

screw_d = 3.2;        // M3貫通穴径
screw_head_d = 6;     // 皿穴径
screw_head_t = 1;     // 皿穴深さ
hole_pitch = 8;       // 穴の間隔
hole_x_offset = 17;   // ピン中心から穴中心までの距離

// --- モジュール: 皿穴 (表面Z=0から削り取る) ---
module countersink_hole() {
    // 貫通穴
    translate([0, 0, -leaf_t - 1])
        cylinder(d = screw_d, h = leaf_t + 2);
    // 皿取りテーパー部
    translate([0, 0, -screw_head_t])
        cylinder(d1 = screw_d, d2 = screw_head_d, h = screw_head_t + 0.001);
}

// --- モジュール: 蝶番の板 (左右共通の基盤) ---
module leaf_base(side="left") {
    difference() {
        union() {
            // 板本体
            if (side == "left") {
                translate([-leaf_w, 0, -leaf_t]) cube([leaf_w, leaf_h, leaf_t]);
            } else {
                translate([0, 0, -leaf_t]) cube([leaf_w, leaf_h, leaf_t]);
            }
            
            // ナックル部分（指定された位置に配置）
            for (i = [0 : segments - 1]) {
                // 左板は 0, 2, 4番目 / 右板は 1, 3番目
                assign_left = (i % 2 == 0);
                if ((side == "left" && assign_left) || (side == "right" && !assign_left)) {
                    translate([0, i * seg_h, 0])
                    rotate([-90, 0, 0])
                    cylinder(d = knuckle_od, h = seg_h);
                }
            }
        }
        
        // ピンを通す中心穴（一括で中空にする）
        rotate([-90, 0, 0])
        translate([0, 0, -1])
        cylinder(d = knuckle_id, h = leaf_h + 2);
        
        // 皿穴 3個の配置
        for (i = [0:2]) {
            y_pos = (leaf_h - (2 * hole_pitch)) / 2 + i * hole_pitch;
            x_pos = (side == "left") ? -hole_x_offset : hole_x_offset;
            translate([x_pos, y_pos, 0])
                countersink_hole();
        }
    }
}

// --- 配置: 左板 (Left Leaf) ---
color("silver")
leaf_base(side="left");

// --- 配置: 右板 (Right Leaf) ---
color("lightgray")
leaf_base(side="right");

// --- 配置: ピン軸 (Pin) ---
color("dimgray")
translate([0, (leaf_h - pin_l) / 2, 0]) // 30mm高に対して32mmを中央寄せ
rotate([-90, 0, 0])
cylinder(d = pin_d, h = pin_l);