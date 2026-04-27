$fn = 100;

// カップ本体のパラメータ
outer_r = 40;     // 外径 80mm
height = 100;    // 高さ 100mm
wall_thick = 4;  // 肉厚 4mm
bottom_thick = 6;// 底の厚み 6mm

// 取手のパラメータ
handle_r = 8;             // 取手の断面半径 (指を通しやすくするため適宜調整)
handle_ring_r = 15;       // 取手のリングの半径
// 取手をカップに接合するためのオフセット調整
// リングの外縁がカップの外周にちょうど触れるように配置
handle_offset = outer_r - 2; 

module mug() {
    difference() {
        // カップの外形
        cylinder(r = outer_r, h = height);
        
        // 内側のくり抜き
        translate([0, 0, bottom_thick])
            cylinder(r = outer_r - wall_thick, h = height - bottom_thick + 0.1);
    }
}

module handle() {
    // カップの側面中心に配置
    // intersectionを使用してカップ本体と不自然に重ならないようにする
    translate([outer_r - 2, 0, height / 2])
        rotate([0, 90, 0])
            rotate_extrude(angle = 360)
                translate([handle_ring_r, 0, 0])
                    circle(r = handle_r);
}

union() {
    mug();
    handle();
}