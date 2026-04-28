// OpenSCADで家具用の小型バット蝶番を作成

// グローバル定数定義
leaf_width = 25;        // 板の横幅 (ヒンジ軸から広がる方向)
leaf_length = 30;       // 板の縦幅 (ヒンジ軸方向)
leaf_thickness = 2;     // 板の厚さ

pin_diameter = 4;       // ピン軸の直径
pin_length = 32;        // ピン軸の長さ (両端1mmずつknuckleから飛び出す)

knuckle_outer_diameter = 8;     // knuckle (筒部) の外径
knuckle_inner_diameter = 4.6;   // knuckle (筒部) の内径 (ピン軸 + 0.3mmクリアランス)
knuckle_segment_length = 6;     // 各knuckleのY方向の長さ (縦30mmを5等分)

hole_diameter_top = 6;          // 皿穴のテーパ部上径
hole_depth_taper = 1;           // 皿穴のテーパ部深さ
hole_diameter_through = 3.2;    // 皿穴の貫通穴径 (M3用)
hole_pitch_y = 8;               // 皿穴のY方向のピッチ

// --- 派生定数 ---
knuckle_count = 5; // knuckleの総数
knuckle_total_length = knuckle_count * knuckle_segment_length; // 全knuckleの合計長さ (30mm)

// ピン軸Y範囲: [0, pin_length]
// knuckleをY軸の [1, 31] の範囲に配置するため、knuckleの開始Y座標を計算
knuckle_start_y = (pin_length - knuckle_total_length) / 2; // = 1mm

// 各knuckleの中心Y座標のリスト
knuckle_centers_y = [
    knuckle_start_y + knuckle_segment_length/2 + 0*knuckle_segment_length, // 4mm
    knuckle_start_y + knuckle_segment_length/2 + 1*knuckle_segment_length, // 10mm
    knuckle_start_y + knuckle_segment_length/2 + 2*knuckle_segment_length, // 16mm
    knuckle_start_y + knuckle_segment_length/2 + 3*knuckle_segment_length, // 22mm
    knuckle_start_y + knuckle_segment_length/2 + 4*knuckle_segment_length  // 28mm
];

// 皿穴のX座標オフセット
// knuckleの中心X=0。外径8mmなので、板の根元はX=4mm。
// 板の幅25mmの中央は12.5mm。したがって、X座標は 4mm + 12.5mm = 16.5mm
hole_offset_x = knuckle_outer_diameter/2 + leaf_width/2; // = 4 + 12.5 = 16.5mm

// 皿穴の中心Y座標のリスト (板の縦方向30mmの中央15mmから8mm間隔)
hole_centers_y = [
    leaf_length/2 - hole_pitch_y, // 15 - 8 = 7mm
    leaf_length/2,                // 15mm
    leaf_length/2 + hole_pitch_y  // 15 + 8 = 23mm
];

// --- モジュール定義 ---

// 1つのknuckle (筒部) を作成するモジュール
// pos_y: knuckleの中心Y座標
// is_outer: trueなら外側の筒形状、falseなら内側の穴形状
module create_knuckle(pos_y, is_outer = true) {
    // knuckleはX=0, Z=0を中心として、Y方向に伸びる円筒として配置
    translate([0, pos_y, 0]) {
        rotate([90, 0, 0]) { // Y軸に沿って配置するために90度回転
            if (is_outer) {
                cylinder(h = knuckle_segment_length, r = knuckle_outer_diameter/2, center = true, $fn=64);
            } else {
                cylinder(h = knuckle_segment_length, r = knuckle_inner_diameter/2, center = true, $fn=64);
            }
        }
    }
}

// 1つの皿穴を生成するモジュール (差分演算で除去するために使用)
// pos_x: 穴のX座標
// pos_y: 穴のY座標
module create_countersunk_hole(pos_x, pos_y) {
    // 板の上面 Z = leaf_thickness/2 を基準に穴を掘り始める
    translate([pos_x, pos_y, leaf_thickness/2]) {
        // テーパ部分 (Z=0を表面として下向きに掘る)
        cylinder(h = hole_depth_taper, r1 = hole_diameter_top/2, r2 = hole_diameter_through/2, $fn=64);
        // 貫通穴部分 (テーパの下から板の裏まで)
        translate([0, 0, -hole_depth_taper]) {
            // 板の厚さ分 + 確実に貫通させるためのわずかなオフセット
            cylinder(h = leaf_thickness + 0.01, r = hole_diameter_through/2, $fn=64);
        }
    }
}

// --- メインアセンブリ ---

// ピン軸
color("silver") {
    // ピン軸はY軸に沿って、Y=0からY=pin_lengthまで伸びるように配置
    rotate([90, 0, 0]) {
        cylinder(h = pin_length, r = pin_diameter/2, $fn=64);
    }
}

// 左板 (x<0 側)
color("darkgray") {
    difference() {
        union() {
            // 基本の板形状を配置
            // X: -(knuckle_outer_diameter/2 + leaf_width) から -knuckle_outer_diameter/2
            // Y: 0 から leaf_length
            // Z: -leaf_thickness/2 から leaf_thickness/2 (Z=0が板の中心)
            translate([-knuckle_outer_diameter/2 - leaf_width, 0, -leaf_thickness/2]) {
                cube([leaf_width, leaf_length, leaf_thickness]);
            }
            // 左板に結合されるknuckleの外側筒を配置: インデックス 0, 2, 4 (Y=4, 16, 28mm)
            for (i = [0, 2, 4]) {
                create_knuckle(knuckle_centers_y[i], true);
            }
        }
        // 左板のknuckleの内側穴を掘る (ピン軸クリアランス用)
        for (i = [0, 2, 4]) {
            create_knuckle(knuckle_centers_y[i], false);
        }
        // 左板の皿穴を掘る
        for (y_center = hole_centers_y) {
            create_countersunk_hole(-hole_offset_x, y_center);
        }
    }
}

// 右板 (x>0 側)
color("darkgray") {
    difference() {
        union() {
            // 基本の板形状を配置
            // X: knuckle_outer_diameter/2 から (knuckle_outer_diameter/2 + leaf_width)
            // Y: 0 から leaf_length
            // Z: -leaf_thickness/2 から leaf_thickness/2 (Z=0が板の中心)
            translate([knuckle_outer_diameter/2, 0, -leaf_thickness/2]) {
                cube([leaf_width, leaf_length, leaf_thickness]);
            }
            // 右板に結合されるknuckleの外側筒を配置: インデックス 1, 3 (Y=10, 22mm)
            for (i = [1, 3]) {
                create_knuckle(knuckle_centers_y[i], true);
            }
        }
        // 右板のknuckleの内側穴を掘る (ピン軸クリアランス用)
        for (i = [1, 3]) {
            create_knuckle(knuckle_centers_y[i], false);
        }
        // 右板の皿穴を掘る
        for (y_center = hole_centers_y) {
            create_countersunk_hole(hole_offset_x, y_center);
        }
    }
}