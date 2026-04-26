$fn = 100;

// マグカップ本体
module mug() {
    difference() {
        // 外形
        cylinder(d = 80, h = 100);
        // 内部をくり抜き（底面厚み 6mm、壁厚 4mm）
        translate([0, 0, 6])
            cylinder(d = 80 - 2 * 4, h = 100 - 6);
    }
}

// リング状取手
module handle() {
    // トーラス（管の半径 r = 12mm、トーラス中心半径 R = 40 + 12 = 52mm）
    rotate_extrude()
        translate([52, 0, 50])
            circle(r = 12);
}

// 結合
union() {
    mug();
    handle();
}