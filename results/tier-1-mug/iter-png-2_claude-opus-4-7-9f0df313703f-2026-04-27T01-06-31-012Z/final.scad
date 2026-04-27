// マグカップ
$fn = 100;

outer_d = 80;      // 外径
height = 100;      // 高さ
wall = 4;          // 肉厚
bottom = 6;        // 底厚
handle_r = 12;     // 取手のリング半径(課題指定どおり)
handle_thick = 8;  // 取手の太さ

module mug() {
    difference() {
        // 外側
        cylinder(h = height, d = outer_d);
        // 内側くり抜き
        translate([0, 0, bottom])
            cylinder(h = height - bottom + 1, d = outer_d - 2 * wall);
    }
}

module handle() {
    // リングがカップ外周から十分はみ出すように、
    // リングの内側端をカップ外周に少しめり込ませて接続する
    translate([outer_d / 2 + handle_r - handle_thick/2, 0, height / 2])
        rotate([90, 0, 0])
            rotate_extrude($fn = 80)
                translate([handle_r, 0, 0])
                    circle(d = handle_thick);
}

union() {
    mug();
    // 取手のうちカップ内部に入り込む部分はカット
    difference() {
        handle();
        translate([0, 0, -1])
            cylinder(h = height + 2, d = outer_d - 0.01);
    }
}