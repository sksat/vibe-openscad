// OpenSCAD: 改善版 butt hinge (180° 開き) - 左板/右板/ピン軸
// 寸法は元の指示に準拠: 左右板 30x25x2, ピン軸 Ø4, 全体 knuckle Ø8, 内径 Ø4.6 (ピン間隙 0.3mm クリアランス)
// knuckle は縦方向 Y に 6mm刻み、左3個・右2個、左右別々の位置に配置
// 左板 x<0, 右板 x>0, 開いた状態は Y 軸中心線を共有して同一平面

// 板の基本寸法
leaf_W = 25;
leaf_H = 30;
leaf_T = 2;

// knuckle/ピンの寸法
knuckle_OD = 8;        // 外径
knuckle_R  = knuckle_OD/2;
pin_D      = 4;        // ピン径
pin_R      = pin_D/2;
hole_d     = 4.6;      // knuckle 内径 (ピン間隙)
hole_R     = hole_d/2;

// knuckle の配置（Y軸方向に 6mmごとに分割）
left_knuckles_Y  = [-12, 0, 12]; // 左板: 外側2個 + 中央1個
right_knuckles_Y = [-6, 6];      // 右板: 中間2個

// 左右板それぞれの knuckle から離れた側の皿穴（M3）位置
// 穴ピッチ 8mm（縦方向）、直径6mmのテーパ+ 直径3.2mm 貫通穴
// テーパはTop面近傍1mm深さ
M3_pocket_Y_left  = [-12, -4, 4];
M3_pocket_Y_right = [-6, 0, 6];

// 内部ヘルパー: knuckle（左用/右用）を X 軸正方向または負方向に配置
module left_knuckle(y) {
    translate([-4, y, 1])
        rotate([90, 0, 0])
            cylinder(h = leaf_H, r = knuckle_R, center = true);
}
module right_knuckle(y) {
    translate([4, y, 1])
        rotate([90, 0, 0])
            cylinder(h = leaf_H, r = knuckle_R, center = true);
}

// M3皿穴の実装（ countersink + through hole ）
module m3_hole_at(x, y) {
    // countersink (6mm diam, depth 1mm from top surface)
    // 上面は z = leaf_T、下は z = leaf_T - 1
    translate([x, y, leaf_T - 1])
        cylinder(h = 1, r1 = 3, r2 = 0, center = false);

    // 貫通穴 (3.2mm dia) 貫通高さは板厚分
    translate([x, y, 0])
        cylinder(h = leaf_T, r = 1.6, center = false);
}

// 左板 (X < 0)
module left_leaf() {
    difference() {
        // 左板: 原点基準で -25 <= X <= 0
        translate([-25, -15, 0])
            cube([25, 30, 2], center = false);

        // knuckle（左板 / 左側の外側2個 + 中央1個）
        for (y = left_knuckles_Y)
            left_knuckle(y);

        // knuckle から離れた側の M3皿穴
        for (y = M3_pocket_Y_left)
            m3_hole_at(-4, y);
    }
}

// 右板 (X > 0)
module right_leaf() {
    difference() {
        // 右板: 0 <= X <= 25
        translate([0, -15, 0])
            cube([25, 30, 2], center = false);

        // knuckle（右板 / 中間2個）
        for (y = right_knuckles_Y)
            right_knuckle(y);

        // knuckle から離れた側の M3皿穴
        for (y = M3_pocket_Y_right)
            m3_hole_at(4, y);
    }
}

// ピン軸（Y軸方向、+Y方向）
// 開いた状態では両板の平面が一致するよう、X=0 の中心線を通る
module pin_axis() {
    // Z軸方向の円柱をY軸方向に回転して配置
    rotate([90, 0, 0])
        cylinder(h = 32, r = pin_R, center = true);
}

// 完成品: 180° 開いた状態で配置
module hinge_open_state() {
    union() {
        left_leaf();
        rotate([0, 180, 0])
            right_leaf();
        pin_axis();
    }
}

// 解像度
$fn = 60;

// 出力
hinge_open_state();