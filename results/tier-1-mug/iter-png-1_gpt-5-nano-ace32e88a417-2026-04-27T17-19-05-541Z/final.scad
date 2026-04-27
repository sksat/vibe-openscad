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
// 外周面に接するよう、半径の組み合わせを R + r = 12 に設定
ring_major = 8;   // major radius of torus
ring_tube  = 4;   // minor radius (tube radius)
ring_center_x = outer_radius; // 外周面に接するよう、中心位置を設定

module ring_handle() {
    translate([ring_center_x, 0, height/2])
        rotate([0, 90, 0])  // リングを側面の平面に配置
            torus(ring_major, ring_tube);
}

union() {
    mug_shell();
    ring_handle();
}