// マグカップ
// 外径: 80mm, 高さ: 100mm, 肉厚: 4mm, 底厚: 6mm

$fn = 128;

// パラメータ
outer_radius = 40;               // 外径80mm → 半径40mm
cup_height   = 100;              // 高さ
wall         = 4;                // 肉厚
bottom       = 6;                // 底面の厚み
inner_radius = outer_radius - wall;  // 内径半径 = 36mm

// 取手パラメータ
handle_tube_r   = 6;             // 取手チューブ断面の半径
handle_ring_r   = 18;            // 取手リング中心半径（リング中心軌跡の半径）
handle_z        = cup_height / 2; // 取手中心高さ（カップ中央）
// リング中心のX座標：カップ外周 + リング半径
handle_cx       = outer_radius + handle_ring_r;

module cup_body() {
    difference() {
        // カップ外側
        cylinder(h = cup_height, r = outer_radius);
        // 内側をくり抜く
        translate([0, 0, bottom])
            cylinder(h = cup_height - bottom + 1, r = inner_radius);
    }
}

module handle() {
    // トーラス状取手（中空）
    difference() {
        // 取手外形トーラス
        translate([handle_cx, 0, handle_z])
            rotate([90, 0, 0])
                rotate_extrude($fn = 128)
                    translate([handle_ring_r, 0, 0])
                        circle(r = handle_tube_r, $fn = 64);

        // 取手内部を中空にする
        translate([handle_cx, 0, handle_z])
            rotate([90, 0, 0])
                rotate_extrude($fn = 128)
                    translate([handle_ring_r, 0, 0])
                        circle(r = handle_tube_r - wall, $fn = 64);
    }
}

// カップ本体と取手を結合し、取手付け根をカップ外周に埋め込む
union() {
    cup_body();

    // 取手本体（トーラス）をカップ外周にオーバーラップさせて配置
    // カップ外周側はカップ本体に埋まり、外側に突き出る
    translate([outer_radius - handle_ring_r + handle_ring_r, 0, 0])
        handle();

    // 取手付け根：カップ外壁に接続する短いシリンダーパッド（上下）
    // 上側接続
    translate([outer_radius - handle_tube_r/2, 0, handle_z + handle_ring_r - handle_tube_r])
        rotate([0, 90, 0])
            cylinder(h = handle_tube_r * 2, r = handle_tube_r, $fn = 64);
    // 下側接続
    translate([outer_radius - handle_tube_r/2, 0, handle_z - handle_ring_r + handle_tube_r - handle_tube_r*2])
        rotate([0, 90, 0])
            cylinder(h = handle_tube_r * 2, r = handle_tube_r, $fn = 64);
}