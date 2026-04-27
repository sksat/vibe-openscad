// マグカップのパラメータ
outer_diameter = 80;
height = 100;
wall_thickness = 4;
bottom_thickness = 6;
handle_radius = 12;
handle_tube_radius = 6;

$fn = 100;

module mug() {
    difference() {
        // 外側の円柱
        cylinder(h = height, d = outer_diameter);
        // 内側をくり抜く
        translate([0, 0, bottom_thickness])
            cylinder(h = height - bottom_thickness + 1, d = outer_diameter - 2 * wall_thickness);
    }
}

module handle() {
    // 取手をカップの中心高さに配置
    translate([outer_diameter / 2 + handle_radius - 2, 0, height / 2])
        rotate([90, 0, 0])
            rotate_extrude()
                translate([handle_radius, 0, 0])
                    circle(r = handle_tube_radius);
}

union() {
    mug();
    handle();
}