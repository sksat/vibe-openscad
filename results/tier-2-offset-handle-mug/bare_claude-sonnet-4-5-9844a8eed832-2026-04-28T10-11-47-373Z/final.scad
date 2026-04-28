$fn = 100;

// パラメータ
outer_diameter = 80;
inner_diameter = 70;
wall_thickness = 5;
height = 90;
bottom_thickness = 6;

// 取手パラメータ
handle_hole_height = 30;
handle_hole_width = 25;
handle_thickness = 5;
handle_vertical_center = height / 2;

difference() {
    union() {
        // 本体外側
        cylinder(d = outer_diameter, h = height);
        
        // 取手（+X軸方向）
        translate([outer_diameter/2, 0, handle_vertical_center]) {
            rotate([0, 90, 0]) {
                difference() {
                    // 取手の外側形状（Dシェイプ）
                    hull() {
                        // 外側の半円部分
                        translate([0, handle_hole_width/2 + handle_thickness, 0])
                            cylinder(d = handle_hole_height + 2*handle_thickness, h = handle_thickness);
                        // 本体接続部分の上下
                        translate([handle_hole_height/2, 0, 0])
                            cube([0.1, 0.1, handle_thickness]);
                        translate([-handle_hole_height/2, 0, 0])
                            cube([0.1, 0.1, handle_thickness]);
                    }
                    // 取手の穴
                    translate([0, handle_hole_width/2 + handle_thickness, -1])
                        cylinder(d = handle_hole_height, h = handle_thickness + 2);
                }
            }
        }
    }
    
    // 内側を削る（飲み物を入れる部分）
    translate([0, 0, bottom_thickness])
        cylinder(d = inner_diameter, h = height);
}