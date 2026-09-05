// マグカップのパラメータ
outer_d = 80;
inner_d = 70;
height = 90;
bottom_thickness = 6;

// 取手のパラメータ
handle_inner_h = 30; // 内側の高さ
handle_inner_w = 25; // 内側の幅（張り出し）
handle_thickness = 10; // 取手自体の肉厚

module mug() {
    union() {
        // マグ本体
        difference() {
            cylinder(d = outer_d, h = height, $fn = 100);
            translate([0, 0, bottom_thickness])
                cylinder(d = inner_d, h = height - bottom_thickness + 0.1, $fn = 100);
        }

        // 取手 (+X軸方向)
        // 本体外径に確実に接合させるため、わずかに本体へめり込ませる
        translate([outer_d / 2 - 2, 0, height / 2]) {
            rotate([0, 90, 0]) {
                linear_extrude(handle_thickness, center = true) {
                    // D字形状：本体側が直線、外側が半円
                    // 内側の空間：高さ 30mm × 幅 25mm
                    difference() {
                        // 外形
                        union() {
                            translate([0, -handle_inner_h / 2 - handle_thickness]) 
                                square([handle_inner_w + handle_thickness, handle_inner_h + handle_thickness * 2]);
                            translate([handle_inner_w + handle_thickness, 0]) 
                                circle(d = handle_inner_h + handle_thickness * 2, $fn = 50);
                        }
                        // 空間 (D字の穴)
                        union() {
                            translate([0, -handle_inner_h / 2]) 
                                square([handle_inner_w, handle_inner_h]);
                            translate([handle_inner_w, 0]) 
                                circle(d = handle_inner_h, $fn = 50);
                        }
                    }
                }
            }
        }
    }
}

mug();