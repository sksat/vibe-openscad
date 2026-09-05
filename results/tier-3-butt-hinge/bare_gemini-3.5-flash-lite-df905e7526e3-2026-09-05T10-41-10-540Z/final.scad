// 家具用小型バット蝶番 (180度開いた状態)
// 単位: mm

// レンダリング品質設定
$fn = 60;

// パラメータ定義
hinge_length = 30.0;     // 縦(Y方向)の長さ
leaf_width = 25.0;       // 横(X方向)の幅
leaf_thick = 2.0;        // 板の厚さ
pin_dia = 4.0;           // ピン直径
pin_length = 32.0;       // ピン全長
clearance = 0.3;         // 可動部のクリアランス
hole_dia = 3.2;          // M3用貫通穴径
countersink_dia = 6.0;   // 皿穴の最大径
countersink_depth = 1.0; // 皿穴の深さ

// knuckleパラメータ
n_segments = 5;          // 5等分
seg_len = hinge_length / n_segments; // 1セグメントの長さ (6mm)
knuckle_out_dia = 8.0;   // 外径
knuckle_in_dia = pin_dia + clearance; // 内径 (4.3mm)

// 組み立て実行
color("Gold") left_leaf();
color("Silver") right_leaf();
color("DarkGray") pin();

// --- 1. 左板 (Left Leaf) ---
// 構成: 本体板 + 左側 knuckle (外側2個 + 中央1個) + 皿穴3個
module left_leaf() {
    difference() {
        union() {
            // 板本体 (x: -leaf_width から 0 まで)
            translate([-leaf_width, -hinge_length/2, -leaf_thick/2])
                cube([leaf_width, hinge_length, leaf_thick]);
            
            // knuckle (セグメント 0, 2, 4) -> 0~6mm, 12~18mm, 24~30mm
            for (i = [0, 2, 4]) {
                translate([0, -hinge_length/2 + i * seg_len, 0])
                    rotate([-90, 0, 0])
                        cylinder(h = seg_len, d = knuckle_out_dia, center = false);
            }
        }
        
        // ピン用貫通穴 (Y軸方向全体)
        translate([0, -pin_length/2 - 2, 0])
            rotate([-90, 0, 0])
                cylinder(h = pin_length + 4, d = knuckle_in_dia);
        
        // M3皿穴 (左板側: x = -leaf_width + オフセット)
        // 縦方向に8mm間隔で3個配置 (-8, 0, +8)
        for (y = [-8, 0, 8]) {
            translate([-leaf_width/2, y, 0]) {
                // 貫通穴 (Z軸方向)
                cylinder(h = leaf_thick * 3, d = hole_dia, center = true);
                // 上面からの皿穴 (表面 Z = leaf_thick/2)
                translate([0, 0, leaf_thick/2 - countersink_depth])
                    cylinder(h = countersink_depth + 0.1, 
                             d1 = hole_dia, 
                             d2 = countersink_dia);
            }
        }
    }
}

// --- 2. 右板 (Right Leaf) ---
// 構成: 本体板 + 右側 knuckle (中間2個) + 皿穴3個
module right_leaf() {
    difference() {
        union() {
            // 板本体 (x: 0 から leaf_width まで)
            translate([0, -hinge_length/2, -leaf_thick/2])
                cube([leaf_width, hinge_length, leaf_thick]);
            
            // knuckle (セグメント 1, 3) -> 6~12mm, 18~24mm
            for (i = [1, 3]) {
                translate([0, -hinge_length/2 + i * seg_len, 0])
                    rotate([-90, 0, 0])
                        cylinder(h = seg_len, d = knuckle_out_dia, center = false);
            }
        }
        
        // ピン用貫通穴 (Y軸方向全体)
        translate([0, -pin_length/2 - 2, 0])
            rotate([-90, 0, 0])
                cylinder(h = pin_length + 4, d = knuckle_in_dia);
        
        // M3皿穴 (右板側: x = leaf_width - オフセット)
        // 縦方向に8mm間隔で3個配置 (-8, 0, +8)
        for (y = [-8, 0, 8]) {
            translate([leaf_width/2, y, 0]) {
                // 貫通穴 (Z軸方向)
                cylinder(h = leaf_thick * 3, d = hole_dia, center = true);
                // 上面からの皿穴 (表面 Z = leaf_thick/2)
                translate([0, 0, leaf_thick/2 - countersink_depth])
                    cylinder(h = countersink_depth + 0.1, 
                             d1 = hole_dia, 
                             d2 = countersink_dia);
            }
        }
    }
}

// --- 3. ピン軸 (Pin) ---
// 直径 4mm, 長さ 32mm (両端 1mm ずつ飛び出し)
module pin() {
    translate([0, -pin_length/2, 0])
        rotate([-90, 0, 0])
            cylinder(h = pin_length, d = pin_dia);
}