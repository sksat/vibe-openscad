// マグカップのパラメータ
outer_d = 80;
inner_d = 70;
height = 90;
bottom_thickness = 6;

// 取手のパラメータ
handle_inner_h = 30;
handle_inner_w = 25;
handle_thickness = 10; // 取手の断面の厚み

module mug() {
    union() {
        // マグ本体
        difference() {
            cylinder(d = outer_d, h = height, $fn = 100);
            translate([0, 0, bottom_thickness])
                cylinder(d = inner_d, h = height - bottom_thickness + 0.1, $fn = 100);
        }

        // 取手 (D字形状: 外側が半円、本体側が直線)
        // 本体外周(半径40mm)に接するように配置
        handle_x_pos = outer_d / 2 - 2; 
        
        translate([handle_x_pos, 0, height / 2]) {
            rotate([0, 90, 0]) {
                linear_extrude(height = handle_thickness) {
                    difference() {
                        // 取手の外形
                        hull() {
                            translate([0, handle_inner_h / 2, 0]) circle(d = handle_thickness, $fn = 50);
                            translate([0, -handle_inner_h / 2, 0]) circle(d = handle_thickness, $fn = 50);
                            translate([handle_inner_w, 0, 0]) circle(d = handle_inner_h + handle_thickness, $fn = 50);
                        }
                        // 取手の内側の穴
                        hull() {
                            translate([0, handle_inner_h / 2, 0]) circle(d = handle_thickness / 2, $fn = 50);
                            translate([0, -handle_inner_h / 2, 0]) circle(d = handle_thickness / 2, $fn = 50);
                            translate([handle_inner_w, 0, 0]) circle(d = handle_inner_h, $fn = 50);
                        }
                    }
                }
            }
        }
    }
}

mug();