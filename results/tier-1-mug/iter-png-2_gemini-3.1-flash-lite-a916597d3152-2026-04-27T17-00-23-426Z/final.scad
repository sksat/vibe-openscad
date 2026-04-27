$fn = 100;

// カップ本体のパラメータ
outer_r = 40;     // 外径 80mm
height = 100;    // 高さ 100mm
wall_thick = 4;  // 肉厚 4mm
bottom_thick = 6;// 底の厚み 6mm

// 取手のパラメータ
handle_r = 12;            // 取手の断面半径
handle_ring_r = 20;       // 取手のリングの半径（中心線までの距離）
// 取手の位置調整：リングがカップにめり込みすぎないよう調整
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
    // カップの側面から突き出すリング状の取手
    translate([handle_offset + handle_r, 0, height / 2])
        rotate([0, 90, 0])
            rotate_extrude(angle = 360)
                translate([handle_ring_r, 0, 0])
                    circle(r = handle_r);
}

union() {
    mug();
    handle();
}