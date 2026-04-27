// パラメータ
cup_outer_diameter = 80;
cup_height = 100;
cup_wall_thickness = 4;
cup_bottom_thickness = 6;

cup_inner_diameter = cup_outer_diameter - 2 * cup_wall_thickness;
cup_inner_height = cup_height - cup_bottom_thickness;

handle_radius = 12;      // リング取手半径
handle_thickness = 8;    // 取手断面厚み 指が通るように
handle_clearance = 6;    // カップ外からのオフセット（ゆとり）

module cup() {
    difference() {
        // 外側のカップ
        cylinder(d=cup_outer_diameter, h=cup_height, $fn=128);

        // 内側 (飲み物が入る部分) --- 上端ぎりぎりまでくり抜き
        translate([0,0,cup_bottom_thickness])
            cylinder(d=cup_inner_diameter, h=cup_height-cup_bottom_thickness, $fn=128);
    }
}

module handle() {
    // 取手中心の位置：カップ外周から浮かせて、中心高さに
    handle_center_offset = (cup_outer_diameter/2) + handle_radius + handle_clearance;

    // 取手はカップ側面に沿ってリング状の切れ目(カップ側で切り欠き)
    angle_span = 220; // 円弧度数（約3/4リング）

    // カップ本体と取手がきちんと繋がるよう、開始/終端をカップ内部に少しめり込ませる
    rotate([90,0,0])
        translate([0,handle_center_offset,cup_height/2])
            rotate([0,0,90])
                arc_torus(handle_radius, handle_thickness/2, angle_span);
}

// 円弧状トーラス(部分リング取手)
module arc_torus(major_r, minor_r, angle) {
    rotate_extrude(angle=angle, $fn=100)
        translate([major_r,0,0]) 
            circle(r=minor_r, $fn=32);
}

// --- 出力 ---
union() {
    cup();
    handle();
}