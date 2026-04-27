// OpenSCAD model: 外径 80mm、高さ 100mm、肉厚 4mm のマグカップ
// 底面の厚み 6mm、内側をくり抜き、側面に半径 12mm の取手（リング状）を付ける
// 取手はカップの中心高さ付近に配置

outer_R = 40;      // 外半径（80mmの直径）
inner_R = 36;      // 内半径（肉厚4mmに対応）
cup_h = 100;       // 高さ
bottomThk = 6;     // 底面の厚み

// 取手の torus（リング）設定
handle_major = 46;   // トーラスの major 半径（R）
handle_tube  = 6;    // トーラスの tube 半径（r） -> 外側へ 2*r = 12mm の突出
// 2R方向の内径が外径と一致するよう、R - r = 40

union() {
    // Cup body: 外形と内側をくり抜く
    difference() {
        // 外形
        cylinder(h = cup_h, r = outer_R, $fn = 200);
        // 内側（底から 6mm 上がった位置から高さ cup_h - bottomThk までの円柱をくり抜く）
        translate([0, 0, bottomThk])
            cylinder(h = cup_h - bottomThk, r = inner_R, $fn = 200);
    }

    // ロング取手（リング状）を取付位置に配置：縦方向の中心をカップの中心高さの付近
    translate([0, 0, cup_h/2]) {
        // torus を作成（xy平面上に ring を生成してから z 方向に適用）
        rotate_extrude(angle = 360, $fn = 200)
            translate([handle_major, 0, 0])
                circle(r = handle_tube);
    }
}