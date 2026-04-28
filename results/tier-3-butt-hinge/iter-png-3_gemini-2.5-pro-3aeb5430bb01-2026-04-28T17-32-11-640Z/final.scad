// OpenSCAD Butt Hinge Generator

// --- 寸法パラメータ ---

// 板(leaf)の寸法
leaf_width = 25;       // 板の幅 (回転軸から外側への長さ)
leaf_length = 30;      // 板の長さ (回転軸に沿った長さ)
leaf_thickness = 2;    // 板の厚さ

// ピン軸の寸法
pin_dia = 4;           // ピンの直径
pin_length = 32;       // ピンの全長

// knuckle(筒部)の寸法
knuckle_od = 8;        // knuckle の外径
knuckle_clearance = 0.3; // ピン穴の半径クリアランス
knuckle_id = pin_dia + 2 * knuckle_clearance; // knuckle の内径(穴径) = 4.6mm
knuckle_segments = 5;  // knuckle の分割数
knuckle_segment_length = leaf_length / knuckle_segments; // 1セグメントの長さ = 6mm

// ネジ穴の寸法 (M3 皿ネジ用)
hole_dia = 3.2;        // 貫通穴の直径
csink_dia = 6;         // 皿穴の表面直径
csink_depth = 1;       // 皿穴の深さ
hole_pitch = 8;        // ネジ穴間のピッチ(Y軸方向)

// 描画品質
$fn = 64;


// --- モジュール定義 ---

// M3皿ネジ用の穴を生成するモジュール
module countersink_hole(h) {
    // 貫通穴
    cylinder(d = hole_dia, h = h + 2, center = true);
    // 皿取り部 (上面に配置)
    translate([0, 0, h/2 - csink_depth])
        cylinder(d1 = csink_dia, d2 = hole_dia, h = csink_depth);
}

// 左板 (knuckle 3個)
module left_leaf() {
    difference() {
        // 板と knuckle の結合
        union() {
            // 板本体
            // knuckle の半径分オフセットして配置
            translate([-leaf_width/2 - knuckle_od/2, 0, 0])
                cube([leaf_width, leaf_length, leaf_thickness], center = true);

            // knuckle (0, 2, 4番目)
            for (i = [0, 2, 4]) {
                y_pos = -leaf_length/2 + knuckle_segment_length * (i + 0.5);
                translate([0, y_pos, 0])
                    cylinder(d = knuckle_od, h = knuckle_segment_length, center = true);
            }
        }
        
        // ピン軸用の貫通穴
        // Y軸に沿って配置
        rotate([90, 0, 0])
            cylinder(d = knuckle_id, h = leaf_length + 2, center = true);

        // M3皿ネジ用の穴 (3個)
        hole_x_pos = -knuckle_od/2 - (leaf_width / 2);
        for (y_pos = [-hole_pitch, 0, hole_pitch]) {
            translate([hole_x_pos, y_pos, 0])
                countersink_hole(leaf_thickness);
        }
    }
}

// 右板 (knuckle 2個)
module right_leaf() {
    difference() {
        // 板と knuckle の結合
        union() {
            // 板本体
            translate([leaf_width/2 + knuckle_od/2, 0, 0])
                cube([leaf_width, leaf_length, leaf_thickness], center = true);

            // knuckle (1, 3番目)
            for (i = [1, 3]) {
                y_pos = -leaf_length/2 + knuckle_segment_length * (i + 0.5);
                translate([0, y_pos, 0])
                    cylinder(d = knuckle_od, h = knuckle_segment_length, center = true);
            }
        }
        
        // ピン軸用の貫通穴
        rotate([90, 0, 0])
            cylinder(d = knuckle_id, h = leaf_length + 2, center = true);

        // M3皿ネジ用の穴 (3個)
        hole_x_pos = knuckle_od/2 + (leaf_width / 2);
        for (y_pos = [-hole_pitch, 0, hole_pitch]) {
            translate([hole_x_pos, y_pos, 0])
                countersink_hole(leaf_thickness);
        }
    }
}

// ピン軸
module hinge_pin() {
    rotate([90, 0, 0])
        cylinder(d = pin_dia, h = pin_length, center = true);
}


// --- 本体描画 (アセンブリ) ---

// 180度開いた状態で各パーツを配置

// 左板
color("Silver")
    left_leaf();

// 右板
color("Silver")
    right_leaf();

// ピン軸
color("DimGray")
    hinge_pin();