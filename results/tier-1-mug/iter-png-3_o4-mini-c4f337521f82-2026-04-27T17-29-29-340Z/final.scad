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

// リング状取手（外周から半径 12mm 飛び出し、断面半径 12mm）
module handle() {
    translate([0, 0, 50])       // カップ中心高さに配置
        rotate_extrude()
            translate([80/2 + 12, 0, 0])  // 外径40 + 飛び出し12 = 52
                circle(r = 12);
}

// 結合
union() {
    mug();
    handle();
}