// 家具用小型バット蝶番 (Butt Hinge)
// OpenSCAD Model

$fn = 60; // 円柱の分割数（滑らかさ）

// --- パラメータ定義 ---
leaf_w = 25;       // 板の幅 (X方向)
leaf_h = 30;       // 板の高さ (Y方向)
leaf_t = 2;        // 板の厚み (Z方向)

pin_d = 4;         // ピン軸の直径
pin_l = 32;        // ピン軸の長さ

knuckle_od = 8;    // knuckle（筒部）の外径
knuckle_id = 4.6;  // knuckleの内径（ピン4mm + 0.3mmクリアランス * 2 = 4.6）
knuckle_h = 6;     // 5等分した1個あたりの高さ（30mm / 5 = 6mm）

screw_d1 = 3.2;    // M3ネジ貫通穴径
screw_d2 = 6.0;    // 皿頭の外径
screw_depth = 1.0; // 皿頭の沈み込み深さ
screw_pitch = 8;   // ネジ穴のピッチ

// --- 共通パーツ ---

// 皿穴（Z軸マイナス方向に貫通、Z=0が表面）
module screw_hole() {
    translate([0, 0, 0.1]) {
        // 皿頭のテーパ部分
        cylinder(d1=screw_d2, d2=screw_d1, h=screw_depth+0.1, center=false);
        // 貫通穴
        translate([0, 0, -(leaf_t + 0.2)])
            cylinder(d=screw_d1, h=leaf_t + 0.2, center=false);
    }
}

// 1枚の板（基本形状、位置調整前）
// side: -1 (左板用), 1 (右板用)
module leaf_plate(side) {
    difference() {
        // メインの板（Z=0が表面、Z=-leaf_tが裏面。knuckleとの接続のため少し重ねる）
        translate([side == -1 ? -leaf_w : 0, 0, -leaf_t])
            cube([leaf_w, leaf_h, leaf_t]);

        // 皿穴 3個
        // X方向は端から8mmの位置、Y方向は中央(15mm)と上下8mmピッチ
        x_pos = side * (leaf_w - 8);
        translate([x_pos, leaf_h/2, 0]) screw_hole();
        translate([x_pos, leaf_h/2 - screw_pitch, 0]) screw_hole();
        translate([x_pos, leaf_h/2 + screw_pitch, 0]) screw_hole();
    }
}

// knuckleの単体（中空円柱、Y軸方向）
module single_knuckle(y_pos) {
    translate([0, y_pos, 0])
    rotate([-90, 0, 0])
    difference() {
        cylinder(d=knuckle_od, h=knuckle_h, center=false);
        translate([0, 0, -0.1])
            cylinder(d=knuckle_id, h=knuckle_h + 0.2, center=false);
    }
}

// --- 各組み立てパーツ ---

// 1. 左板パーツ (x < 0)
// knuckle配置: 1番目(y:0-6), 3番目(y:12-18), 5番目(y:24-30)
module left_assembly() {
    color("LightGray") {
        // 板部分
        leaf_plate(-1);
        
        // knuckleとの接続部をなめらかにする肉盛り
        translate([-knuckle_od/2, 0, -leaf_t])
            cube([knuckle_od/2, leaf_h, leaf_t]);

        // 3つのknuckle
        single_knuckle(0);
        single_knuckle(knuckle_h * 2);
        single_knuckle(knuckle_h * 4);
    }
}

// 2. 右板パーツ (x > 0)
// knuckle配置: 2番目(y:6-12), 4番目(y:18-24)
module right_assembly() {
    color("LightGray") {
        // 板部分
        leaf_plate(1);

        // knuckleとの接続部をなめらかにする肉盛り
        translate([0, 0, -leaf_t])
            cube([knuckle_od/2, leaf_h, leaf_t]);

        // 2つのknuckle
        single_knuckle(knuckle_h);
        single_knuckle(knuckle_h * 3);
    }
}

// 3. ピン軸
module pin() {
    color("DarkGray") {
        // Y軸に沿って配置、両端1mmずつ飛び出す (Y: -1 から 31)
        translate([0, -1, 0])
        rotate([-90, 0, 0])
        cylinder(d=pin_d, h=pin_l);
    }
}

// --- 全体の配置 (180°開いた状態、Y軸が回転中心) ---
left_assembly();
right_assembly();
pin();