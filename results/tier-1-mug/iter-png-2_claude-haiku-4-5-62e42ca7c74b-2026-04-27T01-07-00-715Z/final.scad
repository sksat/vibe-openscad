// マグカップのパラメータ
outer_diameter = 80;
outer_radius = outer_diameter / 2;
height = 100;
wall_thickness = 4;
bottom_thickness = 6;
inner_radius = outer_radius - wall_thickness;

// 取手のパラメータ
handle_tube_radius = 12;      // 取手チューブの半径
handle_major_radius = 50;     // 取手の中心までの距離
handle_center_height = height / 2;

// メインのマグカップ本体
module cup_body() {
    difference() {
        // 外側の円柱
        cylinder(r = outer_radius, h = height, $fn = 100);
        
        // 内側をくり抜く（底面の厚みを考慮）
        translate([0, 0, bottom_thickness])
            cylinder(r = inner_radius, h = height - bottom_thickness + 1, $fn = 100);
    }
}

// 取手（リング状トーラス）
module handle() {
    translate([0, 0, handle_center_height])
        rotate_extrude($fn = 100)
            translate([handle_major_radius, 0, 0])
                circle(r = handle_tube_radius, $fn = 100);
}

// 全体の組み立て
union() {
    cup_body();
    handle();
}