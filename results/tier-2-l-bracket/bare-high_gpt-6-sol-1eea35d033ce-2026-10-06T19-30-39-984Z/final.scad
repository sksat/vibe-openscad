$fn = 64;

width = 50;
horizontal_depth = 40;
vertical_height = 40;
thickness = 3;

hole_diameter = 4.5;
countersink_diameter = 8;
countersink_depth = 2;
edge_offset = 10;
eps = 0.02;

hole_x = [-width / 2 + edge_offset, width / 2 - edge_offset];

difference() {
    union() {
        // 内側コーナーを (Y, Z) = (0, 0) に配置
        translate([-width / 2, 0, -thickness])
            cube([width, horizontal_depth, thickness]);

        translate([-width / 2, -thickness, 0])
            cube([width, thickness, vertical_height]);

        // 2 面をつなぐ外側コーナー
        translate([-width / 2, -thickness, -thickness])
            cube([width, thickness, thickness]);
    }

    for (x = hole_x) {
        // 水平面：外側（下面）に皿座面
        translate([x, horizontal_depth / 2, -thickness - eps])
            cylinder(h = thickness + 2 * eps, d = hole_diameter);

        translate([x, horizontal_depth / 2, -thickness])
            cylinder(
                h = countersink_depth,
                d1 = countersink_diameter,
                d2 = hole_diameter
            );

        // 垂直面：外側（-Y 側）に皿座面
        translate([x, -thickness - eps, vertical_height / 2])
            rotate([-90, 0, 0])
                cylinder(h = thickness + 2 * eps, d = hole_diameter);

        translate([x, -thickness, vertical_height / 2])
            rotate([-90, 0, 0])
                cylinder(
                    h = countersink_depth,
                    d1 = countersink_diameter,
                    d2 = hole_diameter
                );
    }
}