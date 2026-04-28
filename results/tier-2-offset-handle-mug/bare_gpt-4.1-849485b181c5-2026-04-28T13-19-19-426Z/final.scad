// **** パラメータ ****
cup_outer_d = 80;       // 外径 (mm)
cup_inner_d = 70;       // 内径 (mm)
wall_thick = (cup_outer_d - cup_inner_d) / 2;  // 5mm
cup_height = 90;        // 高さ (mm)
bottom_thick = 6;       // 底の厚み (mm)

// 取手パラメータ
handle_hole_h = 30;     // 取手内側高さ (mm)
handle_hole_w = 25;     // 取手内側幅 (mm)
handle_thick = 10;      // 取手断面厚み (mm)
handle_clear = 2;       // 取手と本体間の最小隙間(0～2mm)
handle_outer_r = (handle_hole_w + handle_thick * 2) / 2;    // 外半径
handle_offset_z = (cup_height - handle_hole_h) / 2;          // 取手取付高さ

// **** マグ本体 ****
module mug_body() {
    difference() {
        // 外筒
        cylinder(d = cup_outer_d, h = cup_height, $fn=128);
        // 内空間
        translate([0,0,bottom_thick])
            cylinder(d = cup_inner_d, h = cup_height-bottom_thick, $fn=128);
    }
}

// **** ハンドル (D字型) ****
module mug_handle() {
    // D 字外側のパス用パラメータ
    r = handle_outer_r;
    hole_h = handle_hole_h;
    straight_len = hole_h;  // 直線部(上下に伸びる)
    handle_len = hole_h + handle_thick * 2; // 外枠高さ

    // D 字の中心点 (本体からの位置)
    x_offset = cup_outer_d/2 - handle_clear + r;
    y_offset = 0;
    z_offset = handle_offset_z - handle_thick;

    // D字外形パス(半円+直線)
    path_points = concat(
        [for(a=[90:-180:-90]) [r*cos(a), r*sin(a)]],  // 半円(下→上, Y軸正方向)
        [
            [ -r, -r ],
            [ -r, r ]
        ]
    );

    // D字外形
    difference() {
        // 外
        translate([x_offset, y_offset, handle_offset_z-handle_thick])
            linear_extrude(height=handle_len)
                polygon(points = concat(
                    [for(a=[90:-1:-90]) [r*cos(a), r*sin(a)]],  // 半円(下→上)
                    [[-r, -r],[ -r, r]]
                ));

        // 内（指が入る空間）
        translate([
            x_offset, y_offset, handle_offset_z
        ])
            linear_extrude(height=handle_hole_h)
                polygon(points = concat(
                    [for(a=[90:-1:-90]) [handle_hole_w/2*cos(a), handle_hole_w/2*sin(a)]],
                    [[-handle_hole_w/2, -handle_hole_w/2],[ -handle_hole_w/2, handle_hole_w/2]]
                ));
    }
}

// **** 全体 ****
union() {
    mug_body();
    mug_handle();
}