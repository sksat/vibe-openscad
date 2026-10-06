$fn = 64;

width = 50;
flange_length = 40;
thickness = 3;

hole_diameter = 4.5;
countersink_diameter = 8;
countersink_depth = 2;

hole_x = [-width / 2 + 10, width / 2 - 10];

difference() {
    union() {
        // 内側コーナーを Y=0, Z=0 に配置
        translate([-width / 2, 0, -thickness])
            cube([width, flange_length, thickness]);

        translate([-width / 2, -thickness, 0])
            cube([width, thickness, flange_length]);
    }

    for (x = hole_x) {
        // 水平面：外側（下面）に皿座面
        translate([x, flange_length / 2, -thickness])
            cylinder(h = thickness, d = hole_diameter);

        translate([x, flange_length / 2, -thickness])
            cylinder(
                h = countersink_depth,
                d1 = countersink_diameter,
                d2 = hole_diameter
            );

        // 垂直面：外側（背面）に皿座面
        translate([x, -thickness, flange_length / 2])
            rotate([-90, 0, 0]) {
                cylinder(h = thickness, d = hole_diameter);
                cylinder(
                    h = countersink_depth,
                    d1 = countersink_diameter,
                    d2 = hole_diameter
                );
            }
    }
}