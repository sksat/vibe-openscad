// 家具用小型バット蝶番 (Butt Hinge)
// 3つのパーツ: 左板(Left Leaf), 右板(Right Leaf), ピン軸(Pin)

// --- パラメータ設定 ---
leaf_w = 25;          // 横幅 (回転方向)
leaf_h = 30;          // 縦幅 (ピン軸方向)
leaf_t = 2;           // 厚さ
pin_d = 4;            // ピン軸直径
pin_l = 32;           // ピン軸長さ
knuckle_d = 8;        // Knuckle外径
knuckle_id = 4.6;     // Knuckle内径 (4.0 + 0.3*2)
knuckle_h = 6;        // 各Knuckleの高さ (30mm / 5)
m3_hole_d = 3.2;      // M3貫通穴直径
m3_csc_d = 6;         // 皿穴直径
m3_csc_dep = 1;       // 皿穴深さ
m3_pitch = 8;         // 穴ピッチ

// --- モジュール定義 ---

// 皿穴と貫通穴 (Z軸方向に配置)
module m3_hole() {
    difference() {
        // 貫通穴 (厚み+αの長さで貫通を保証)
        cylinder(h = leaf_t + 2, d = m3_hole_d, center = false);
        // 皿穴 (表面から1mmのテーパー)
        translate([0, 0, -0.5])
            cylinder(h = m3_csc_dep + 0.5, d1 = m3_csc_d, d2 = m3_hole_d, center = false);
    }
}

// 片側の板 (Knuckleを含む)
module leaf_part(is_left = true) {
    // 座標のオフセット: 左板は -25 から 0、右板は 0 から 25 に配置
    offset_x = is_left ? -leaf_w : 0;
    
    // Knuckleの配置位置 (Y軸方向)
    // 左板は外側2個+中央1個、右板は中間2個
    knuckle_y_pos = is_left ? [-12, 0, 12] : [-6, 6];
    
    difference() {
        union() {
            // 板本体 (Y軸中心に配置するため -leaf_h/2 から開始)
            translate([offset_x, -leaf_h/2, 0])
                cube([leaf_w, leaf_h, leaf_t]);
            
            // Knuckleの配置
            for (y_pos = knuckle_y_pos) {
                translate([0, y_pos, 0])
                    cylinder(h = knuckle_h, d = knuckle_d, center = false);
            }
        }
        
        // ピン軸の通り道（Knuckle内）をくり抜く
        for (y_pos = knuckle_y_pos) {
            translate([0, y_pos, -1])
                cylinder(h = knuckle_h + 2, d = knuckle_id, center = false);
        }
        
        // M3穴の配置 (Knuckleから離れた側)
        // 板の端 (X = -25 または X = 25) に配置
        // 皿穴は表面（Z方向）に掘るため、回転は不要
        for (y_pos = [-8, 0, 8]) {
            translate([is_left ? -leaf_w : leaf_w, y_pos, leaf_t/2])
                m3_hole();
        }
    }
}

// --- 組み立て ---

// 左板 (x < 0 側に伸びる)
leaf_part(is_left = true);

// 右板 (x > 0 側に伸びる)
leaf_part(is_left = false);

// ピン軸 (中心をY軸に重ねる)
// 長さ32mm、両端1mmずつKnuckleから飛び出す (Knuckle範囲はY=-15〜15)
translate([0, 0, 0])
    cylinder(h = pin_l, d = pin_d, center = true);