// Sharp GP2Y0D413K0F 距離センサ モデル
// 単位: mm
// 座標系: 本体中心を原点 (0,0,0)
// 取付面(PWB/コネクタ)が -Z 方向

$fn = 50;

module gp2y0d413k0f() {
    // 全体サイズ: 29.45(W) x 18.9(H) x 13.5(D)
    // 中心を原点とするため、各寸法を半分にして計算
    width = 29.45;
    height = 18.9;
    depth = 13.5;
    
    // ボディ本体
    color("gray") {
        translate([0, 0, -depth/2 + 6.75]) // 全体のZ中心オフセット調整
        cube([width, height, depth], center = true);
    }

    // レンズ部 (突出している部分)
    // 側面図より: レンズケースの突起はZ方向に突出
    translate([0, 7.2/2 + (18.9-7.2)/2, 0])
    color("black")
    translate([0, 0, (depth/2 + 2)/2 - 1])
    cube([13.05, 7.2, 2], center=true);

    // レンズ本体 (2つの円筒)
    // 左右対称に配置
    for (x = [-7.6, 7.6]) { // 19.7の半分付近
        color("darkgray")
        translate([x, 0, depth/2 + 0.5])
        cylinder(r = 3.5/2, h = 1);
    }

    // コネクタ部 (PWB側 -Z面)
    color("white")
    translate([0, -(height/2 - 3.3/2), -depth/2 - 3.3/2])
    cube([10.1, 3.3, 3.3], center=true);

    // PWB部分 (厚さ 1.2mm)
    color("brown")
    translate([0, -(height/2 - 1.2/2), -depth/2 - 0.6])
    cube([width, 1.2, 1.2], center=true);
}

// 実行
gp2y0d413k0f();