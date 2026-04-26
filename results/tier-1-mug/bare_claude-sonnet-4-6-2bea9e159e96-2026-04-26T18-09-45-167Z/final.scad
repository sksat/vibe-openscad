// マグカップ
// 外径: 80mm, 高さ: 100mm, 肉厚: 4mm, 底厚: 6mm

$fn = 128;

// パラメータ
outer_radius = 40;       // 外径80mm → 半径40mm
cup_height   = 100;      // 高さ
wall         = 4;        // 肉厚
bottom       = 6;        // 底面の厚み
inner_radius = outer_radius - wall;  // 内径半径 = 36mm

// 取手パラメータ
handle_tube_radius  = 6;    // 取手チューブの断面半径
handle_ring_radius  = 18;   // 取手リングの中心半径（リング中心までの距離）
handle_height       = cup_height / 2;  // カップ中心高さ
handle_offset       = outer_radius + handle_ring_radius; // リング中心のX座標

difference() {
    union() {
        // カップ本体（外側シリンダー）
        cylinder(h = cup_height, r = outer_radius);

        // 取手：トーラス状リング（側面に接続）
        translate([handle_offset, 0, handle_height])
            rotate([90, 0, 0])
                rotate_extrude(angle = 360, $fn = 128)
                    translate([handle_ring_radius, 0, 0])
                        circle(r = handle_tube_radius, $fn = 64);
    }

    // 内側をくり抜く（底面を残す）
    translate([0, 0, bottom])
        cylinder(h = cup_height - bottom + 1, r = inner_radius);

    // 取手の内部をくり抜く（中空チューブにする）
    translate([handle_offset, 0, handle_height])
        rotate([90, 0, 0])
            rotate_extrude(angle = 360, $fn = 128)
                translate([handle_ring_radius, 0, 0])
                    circle(r = handle_tube_radius - wall, $fn = 64);

    // 取手とカップ本体の接合部の穴を開けて指が通るようにする
    // （カップ内部のくり抜きがリング中心空洞と干渉しないよう、
    //   取手内部の穴がカップ外壁を貫通する部分のみ除去）
    // 取手内部空洞（カップ壁を通り抜ける穴）
    translate([outer_radius - wall - 0.5, 0, handle_height])
        rotate([0, 90, 0])
            cylinder(h = wall * 2 + 1, r = handle_tube_radius - wall, $fn = 64);
}