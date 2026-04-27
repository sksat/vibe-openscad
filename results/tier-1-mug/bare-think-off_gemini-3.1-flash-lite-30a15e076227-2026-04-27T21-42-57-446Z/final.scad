$fn = 100;

// カップのパラメータ
outer_d = 80;
height = 100;
wall_thickness = 4;
bottom_thickness = 6;

// 取手のパラメータ
handle_r = 12; // 取手の断面半径
handle_offset = 35; // カップ中心からの距離
handle_center_z = height / 2;

module mug() {
    difference() {
        // カップの外形
        cylinder(d = outer_d, h = height);

        // 中をくり抜く
        translate([0, 0, bottom_thickness])
            cylinder(d = outer_d - wall_thickness * 2, h = height - bottom_thickness + 0.1);
    }

    // 取手
    translate([outer_d / 2 - wall_thickness / 2, 0, handle_center_z]) {
        rotate([0, 90, 0]) {
            rotate_extrude(angle = 360) {
                translate([handle_offset, 0, 0])
                    circle(r = handle_r);
            }
        }
    }
}

mug();