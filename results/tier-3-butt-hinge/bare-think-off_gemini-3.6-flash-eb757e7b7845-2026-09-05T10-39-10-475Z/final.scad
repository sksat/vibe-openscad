$fn = 64;

// パラメータ定義
leaf_length = 30;       // 縦方向 (Y軸)
leaf_width = 25;        // 横方向 (X軸)
leaf_thickness = 2;     // 板厚 (Z軸)

pin_dia = 4;            // ピン径
pin_length = 32;        // ピン長さ

knuckle_od = 8;         // ナックル外径
clearance = 0.3;        // ピンとナックル内径のクリアランス
knuckle_id = pin_dia + clearance; // ナックル内径 (4.3mm)

num_knuckles = 5;
knuckle_len = leaf_length / num_knuckles; // 6mm

screw_pass_dia = 3.2;   // M3貫通穴径
screw_head_dia = 6.0;   // 皿頭径
screw_head_depth = 1.0; // 皿頭深さ
screw_pitch = 8;        // 穴ピッチ (Y方向)

// 単体プレート（板部＋ナックル部）を生成するモジュール
module leaf_with_knuckles(knuckle_indices) {
    difference() {
        union() {
            // 板部: X=0からX方向(正または負)へ伸びる
            // 平らな上面が Z=0 になるように配置 (Z: -leaf_thickness ～ 0)
            translate([0, 0, -leaf_thickness])
                cube([leaf_width, leaf_length, leaf_thickness]);

            // ナックル部 (指定されたインデックスの位置に配置)
            for (i = knuckle_indices) {
                translate([0, i * knuckle_len, 0])
                    rotate([-90, 0, 0])
                        cylinder(d = knuckle_od, h = knuckle_len);
            }
        }

        // ピン用の貫通穴 (Y軸に沿う中心穴)
        translate([0, -1, 0])
            rotate([-90, 0, 0])
                cylinder(d = knuckle_id, h = leaf_length + 2);

        // 皿穴 (3箇所)
        // Y方向: 中央(15mm)を中心に screw_pitch(8mm) 間隔で配置 (7mm, 15mm, 23mm)
        // X方向: ナックルから離れた側 (X = 16mm)
        hole_x = 16;
        for (y_pos = [leaf_length/2 - screw_pitch, leaf_length/2, leaf_length/2 + screw_pitch]) {
            translate([hole_x, y_pos, 0]) {
                // 皿頭テーパ部
                translate([0, 0, -screw_head_depth])
                    cylinder(h = screw_head_depth + 0.01, d1 = screw_pass_dia, d2 = screw_head_dia);
                // 貫通穴部
                translate([0, 0, -leaf_thickness - 1])
                    cylinder(h = leaf_thickness + 2, d = screw_pass_dia);
            }
        }
    }
}

// 1. 左板 (x < 0 側に配置、ナックルは index 0, 2, 4)
mirror([1, 0, 0]) {
    leaf_with_knuckles([0, 2, 4]);
}

// 2. 右板 (x > 0 側に配置、ナックルは index 1, 3)
leaf_with_knuckles([1, 3]);

// 3. ピン軸 (両端 1mm ずつ突出: Y = -1 から 31mm)
color("silver")
translate([0, -1, 0])
    rotate([-90, 0, 0])
        cylinder(d = pin_dia, h = pin_length);