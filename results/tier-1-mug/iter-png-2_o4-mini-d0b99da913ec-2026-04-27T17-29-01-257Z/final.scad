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

// リング状取手（指が通る部分が外径から12mm飛び出す）
module handle() {
    // プロファイルとして円(r=6)を、X=46, Y=50 の位置に置いて回転押し出し
    // -> 内側R=46-6=40でカップに接触、外側R=46+6=52で外径40から12mm突出
    rotate_extrude($fn = 100)
        translate([46, 50])
            circle(r = 6, $fn = 50);
}

// 結合
union() {
    mug();
    handle();
}