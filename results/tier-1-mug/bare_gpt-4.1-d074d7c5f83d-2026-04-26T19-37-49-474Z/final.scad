// パラメータ
cup_outer_diameter = 80;
cup_height = 100;
cup_wall_thickness = 4;
cup_bottom_thickness = 6;

cup_inner_diameter = cup_outer_diameter - 2 * cup_wall_thickness;
cup_inner_height = cup_height - cup_bottom_thickness;

handle_radius = 12;
handle_thickness = 4; // リング取手の断面厚み
handle_clearance = 6; // カップ外からの飛び出し余裕

module cup() {
    difference() {
        // 外側のカップ
        cylinder(d=cup_outer_diameter, h=cup_height, $fn=128);

        // 内側 (飲み物が入る部分)
        translate([0,0,cup_bottom_thickness])
            cylinder(d=cup_inner_diameter, h=cup_inner_height, $fn=128);
    }
}

module handle() {
    // 取手の中心がカップ外周から sufficient clearance で外側に出るように配置
    // y方向(外径方向)にオフセット
    angle_span = 220; // 取手リングの円弧(度)
    angle_start = -angle_span/2;
    angle_end = angle_span/2;
    // 取手の中心位置
    handle_center_offset = (cup_outer_diameter/2) + handle_radius + handle_clearance;

    // 取手(トーラスの一部)の断面円
    rotate([90,0,0])
        translate([0,handle_center_offset,cup_height/2])
            rotate([0,0,90])
                arc_torus(handle_radius, handle_thickness/2, angle_span);
}

// 部分的なトーラス(円弧状の取手)
module arc_torus(major_r, minor_r, angle) {
    // angle: 度数法で制限
    $fn_arc = 100;    // 精度
    rotate_extrude(angle=angle, $fn=$fn_arc)
        translate([major_r,0,0])
            circle(r=minor_r, $fn=32);
}

// マグカップ本体＋取手
union() {
    cup();
    handle();
}