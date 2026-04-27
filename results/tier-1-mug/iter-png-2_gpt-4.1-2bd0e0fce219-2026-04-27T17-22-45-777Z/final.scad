// パラメータ
cup_outer_diameter = 80;
cup_height = 100;
cup_wall_thickness = 4;
cup_bottom_thickness = 6;

cup_inner_diameter = cup_outer_diameter - 2 * cup_wall_thickness;
cup_inner_height = cup_height - cup_bottom_thickness;

handle_radius = 12;      // リング取手半径
handle_thickness = 8;    // 取手の断面厚み
handle_offset = 4;       // カップ外周から取手始点まで(ゆとり)

// カップ本体
module cup() {
    difference() {
        // 外側
        cylinder(d=cup_outer_diameter, h=cup_height, $fn=128);
        // 内側(底厚さぶん、底上げ)
        translate([0,0,cup_bottom_thickness])
            cylinder(d=cup_inner_diameter, h=cup_height-cup_bottom_thickness, $fn=128);
    }
}

// 取手本体：カップ外径に密着＋十分外側に飛び出す
module handle() {
    angle_span = 220; // 円弧 span（だいたい3/4）
    handle_center_dist = (cup_outer_diameter/2) + handle_radius + handle_offset;
    // カップ中心高さに取手の中心、Y方向に配置
    translate([0, 0, cup_height/2])
        rotate([0,0,90])
            translate([0, handle_center_dist, 0])
                rotate([0,0,-angle_span/2])
                    arc_torus(handle_radius, handle_thickness/2, angle_span);
}

// 部分トーラス生成
module arc_torus(major_r, minor_r, angle) {
    rotate_extrude(angle=angle, $fn=100)
        translate([major_r,0,0]) 
            circle(r=minor_r, $fn=32);
}

union() {
    cup();
    handle();
}