// マグカップ パラメータ
outer_diameter = 80;     // 外径
height = 100;            // 高さ
wall_thickness = 4;      // 肉厚
bottom_thickness = 6;    // 底面の厚み

outer_radius = outer_diameter / 2;
inner_radius = outer_radius - wall_thickness;

// 取手パラメータ
handle_ring_radius = 12;  // リング取手の半径(穴の半径)
handle_tube_radius = 4;   // 取手の太さ
handle_height = height / 2;  // 取手の高さ位置(カップの中心)

$fn = 100;

module mug_body() {
    difference() {
        // 外側の円筒
        cylinder(h = height, r = outer_radius);
        // 内側をくり抜く
        translate([0, 0, bottom_thickness])
            cylinder(h = height - bottom_thickness + 1, r = inner_radius);
    }
}

module handle() {
    // リング状の取手をカップの側面に取り付ける
    // 取手の中心を、カップ外周から少し離した位置に配置
    handle_center_x = outer_radius + handle_ring_radius - handle_tube_radius / 2;
    
    translate([handle_center_x, 0, handle_height])
        rotate([90, 0, 0])
            rotate_extrude($fn = 100)
                translate([handle_ring_radius, 0, 0])
                    circle(r = handle_tube_radius, $fn = 50);
}

// 完成形
union() {
    mug_body();
    // 取手はカップ本体と重なる部分も含めて配置
    intersection_or_union: handle();
}