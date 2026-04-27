// マグカップのパラメータ
outer_d = 80;      // 外径
height = 100;      // 高さ
wall_t = 4;        // 壁厚
bottom_t = 6;      // 底厚
handle_offset = 12; // 取手のカップ外壁からの突出量
handle_r = 6;      // 取手チューブの断面半径

module mug() {
    // 外形
    cylinder(h = height, r = outer_d/2, $fn=100);
    // 内部くり抜き
    translate([0,0,bottom_t])
        cylinder(h = height - bottom_t, r = outer_d/2 - wall_t, $fn=100);
}

module handle() {
    // トーラス風の取手 (rotate_extrude)
    translate([outer_d/2 + handle_offset, 0, height/2])
        rotate_extrude($fn=100)
            translate([handle_r, 0, 0])
                circle(r = handle_r, $fn=50);
}

difference() {
    mug();
    // 内部をくり抜く
    translate([0,0,0])
        // 図形を上位で差分扱い（既に内側だけくり抜いているため不要ですが構造示すため）
        // ここは空
        cube([0,0,0]);
}
union() {
    // カップ本体
    mug();
    // 取手を追加
    handle();
}