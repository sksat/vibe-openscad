$fn = 64;

width = 50;
flange_length = 40;
thickness = 3;

hole_diameter = 4.5;
countersink_diameter = 8;
countersink_depth = 2;
edge_offset = 10;
eps = 0.01;

// 両フランジの内側コーナーを (Y, Z) = (0, 0) に配置
outer_edge = flange_length - thickness;
hole_position = (outer_edge - thickness) / 2;

difference() {
    union() {
        // 水平フランジ
        translate([-width/2, -thickness, -thickness])
            cube([width, flange_length, thickness]);

        // 垂直フランジ
        translate([-width/2, -thickness, -thickness])
            cube([width, thickness, flange_length]);
    }

    for (x = [-width/2 + edge_offset, width/2 - edge_offset]) {
        // 水平面：外側（下面）から皿穴を加工
        translate([x, hole_position, -thickness - eps])
            cylinder(d = hole_diameter, h = thickness + 2*eps);
        translate([x, hole_position, -thickness - eps])
            cylinder(
                d1 = countersink_diameter,
                d2 = hole_diameter,
                h = countersink_depth + eps
            );

        // 垂直面：外側（背面）から皿穴を加工
        translate([x, -thickness - eps, hole_position])
            rotate([-90, 0, 0])
                cylinder(d = hole_diameter, h = thickness + 2*eps);
        translate([x, -thickness - eps, hole_position])
            rotate([-90, 0, 0])
                cylinder(
                    d1 = countersink_diameter,
                    d2 = hole_diameter,
                    h = countersink_depth + eps
                );
    }
}