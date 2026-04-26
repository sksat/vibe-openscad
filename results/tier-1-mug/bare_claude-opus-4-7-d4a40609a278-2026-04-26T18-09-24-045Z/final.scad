// マグカップ
$fn = 100;

outer_d = 80;      // 外径
height = 100;      // 高さ
wall = 4;          // 肉厚
bottom = 6;        // 底厚
handle_r = 12;     // 取手のリング半径(穴の半径)
handle_thick = 6;  // 取手の太さ

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
    // カップの中心高さに配置
    translate([outer_d / 2, 0, height / 2])
        rotate([90, 0, 0])
            rotate_extrude($fn = 80)
                translate([handle_r, 0, 0])
                    circle(d = handle_thick);
}

union() {
    mug();
    // 取手の一部がカップ内部に被らないよう、外側部分のみ残す
    difference() {
        handle();
        cylinder(h = height + 1, d = outer_d - 0.01);
    }
}