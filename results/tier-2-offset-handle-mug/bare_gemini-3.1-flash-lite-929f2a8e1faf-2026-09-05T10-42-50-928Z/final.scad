// マグカップのパラメータ
outer_d = 80;
inner_d = 70;
height = 90;
bottom_thickness = 6;
wall_thickness = 5;

// 取手のパラメータ
handle_inner_h = 30;
handle_inner_w = 25;
handle_thickness = 10;

module mug() {
    union() {
        // マグ本体
        difference() {
            cylinder(d = outer_d, h = height, $fn = 100);
            translate([0, 0, bottom_thickness])
                cylinder(d = inner_d, h = height - bottom_thickness + 0.1, $fn = 100);
        }

        // 取手
        handle_x_offset = outer_d / 2 - 1; // 本体と重なりを持たせる
        handle_total_w = handle_inner_w + handle_thickness * 2;
        handle_total_h = handle_inner_h + handle_thickness * 2;

        translate([handle_x_offset, 0, height / 2]) {
            difference() {
                // 取手の外形
                rotate([90, 0, 90])
                    linear_extrude(height = handle_thickness) {
                        hull() {
                            translate([0, handle_inner_h / 2, 0]) circle(d = handle_thickness);
                            translate([0, -handle_inner_h / 2, 0]) circle(d = handle_thickness);
                            translate([handle_inner_w + handle_thickness / 2, 0, 0]) 
                                scale([1, handle_total_h / handle_total_w]) circle(d = handle_total_w);
                        }
                    }
                // 取手の内側の穴
                rotate([90, 0, 90])
                    translate([handle_thickness / 2, 0, -1])
                        linear_extrude(height = handle_thickness + 2) {
                            hull() {
                                translate([0, handle_inner_h / 2, 0]) circle(d = handle_thickness);
                                translate([0, -handle_inner_h / 2, 0]) circle(d = handle_thickness);
                                translate([handle_inner_w - handle_thickness / 2, 0, 0]) circle(d = handle_thickness);
                            }
                        }
            }
        }
    }
}

mug();