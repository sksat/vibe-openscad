$fn = 100;

outer_radius = 40;           // 外径 80 mm -> 半径 40 mm
wall_thickness = 4;
bottom_thickness = 6;
height = 100;

inner_radius = outer_radius - wall_thickness;
cavity_height = height - bottom_thickness;

// マグカップの外形と内腔を作成
module mug_shell() {
    difference() {
        // 外形（実体）
        cylinder(h = height, r = outer_radius, center = false);
        // 内腔（くり抜き、底の厚みは bottom_thickness）
        translate([0, 0, bottom_thickness])
            cylinder(h = cavity_height, r = inner_radius, center = false);
    }
}

// トーラス（輪っか）を作成するヘルパー
module torus(R, r) {
    rotate_extrude(angle = 360)
        translate([R, 0, 0])
            circle(r = r);
}

// 取手（リング状のリング）を側面に取り付ける
module ring_handle() {
    // 外周から十分にはみ出すよう、外側に位置させる
    // major radius 12 mm（要求の半径）とし、薄い輪っかにする
    // 取手はカップの中高さ付近に配置
    translate([outer_radius + 12, 0, height/2])
        rotate([0, 90, 0])  // リングを側面の平面に配置
            torus(12, 4);
}

union() {
    mug_shell();
    ring_handle();
}