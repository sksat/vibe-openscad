// 外径 80mm, 高さ 100mm, 肉厚 4mm, 底面厚 6mm, 内側くり抜き
// 側面取手は半径 12mm のリング状

module mug() {
    outer_r = 40;          // 外径/半径
    wall = 4;               // 肉厚
    height = 100;           // 外形高さ
    bottom_thickness = 6;   // 底厚
    inner_h = height - bottom_thickness; // 内部有効高
    inner_r = outer_r - wall; // 内径半径

    // 外形筒
    difference() {
        // 外形の筒
        cylinder(h = height, r = outer_r, center = false);

        // 内部をくり抜く（底厚を確保するため、下方向に底厚分ずらしてくり抜く）
        translate([0, 0, bottom_thickness])
            cylinder(h = inner_h, r = inner_r, center = false);
    }
}

// 指定位置に取手を追加
module handle_ring() {
    // 取手のリングは外周から外にはみ出すように
    // 主半径 R = 外径半径 + 12mm = 40 + 12 = 52
    // チューブの断面半径 r = 6mm
    R = 52;
    r = 6;

    // torus を作成: major radius R, minor radius r
    // torus を z 軸周りに作るには rotate_extrude ベース
    // 現状の中心を cup の中心軸に合わせるため、Z = height/2 = 50 に配置
    translate([0, 0, 50])
        rotate([0, 90, 0])
            torus(R, r);
}

// torus 作成モジュール
// R : major radius（トーラスの中心円の半径）
// r : minor radius（断面半径）
module torus(R, r) {
    // rotate_extrude は 2D を回転して 3D にする。円を X 軸方向に配置して回す
    rotate_extrude($fn = 120)
        translate([R, 0, 0])
            circle(r = r, $fn = 60);
}

union() {
    mug();
    handle_ring();
}