// バット蝶番（180°開いた状態）

// パラメータ
leaf_width = 25;    // 板の幅
leaf_height = 30;   // 板の高さ
leaf_thickness = 2; // 板の厚み
knuckle_od = 8;     // knuckle外径
pin_diameter = 4;   // ピン軸径
pin_clearance = 0.3; // ピンクリアランス
knuckle_id = pin_diameter + pin_clearance; // knuckle内径
pin_length = 32;    // ピン軸長さ
knuckle_length = 6; // 各knuckle長さ

// 皿穴パラメータ
screw_hole_dia = 3.2;
countersink_dia = 6;
countersink_depth = 1;
screw_spacing = 8;

module leaf_with_knuckles(knuckle_positions, side) {
    difference() {
        union() {
            // メイン板
            translate([side * leaf_width/2, 0, -leaf_thickness/2])
                cube([leaf_width, leaf_height, leaf_thickness], center=true);
            
            // knuckles
            for (pos = knuckle_positions) {
                translate([0, pos, 0])
                    cylinder(h=knuckle_length, d=knuckle_od, center=true);
            }
        }
        
        // knuckle穴（ピン軸用）
        for (pos = knuckle_positions) {
            translate([0, pos, 0])
                cylinder(h=knuckle_length+0.1, d=knuckle_id, center=true);
        }
        
        // 皿穴
        for (i = [0:2]) {
            screw_y = -leaf_height/2 + 6 + i * screw_spacing;
            translate([side * leaf_width * 0.7, screw_y, 0]) {
                // 貫通穴
                cylinder(h=leaf_thickness+1, d=screw_hole_dia, center=true);
                // 皿穴（表面側）
                translate([0, 0, leaf_thickness/2 - countersink_depth + 0.1])
                    cylinder(h=countersink_depth+0.1, d1=screw_hole_dia, d2=countersink_dia);
            }
        }
    }
}

// knuckle位置（Y座標、30mmを5等分）
// -12, -6, 0, 6, 12 (各6mm間隔)

// 左板（x<0側、knuckle位置: 1番目、3番目、5番目）
left_knuckle_positions = [-12, 0, 12];
leaf_with_knuckles(left_knuckle_positions, -1);

// 右板（x>0側、knuckle位置: 2番目、4番目）
right_knuckle_positions = [-6, 6];
leaf_with_knuckles(right_knuckle_positions, 1);

// ピン軸（Y軸方向）
cylinder(h=pin_length, d=pin_diameter, center=true);