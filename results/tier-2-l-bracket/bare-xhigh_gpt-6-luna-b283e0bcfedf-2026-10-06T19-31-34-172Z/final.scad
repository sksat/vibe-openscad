width = 50;
depth = 40;
height = 40;
thickness = 3;

hole_d = 4.5;
countersink_d = 8;
countersink_depth = 2;
edge_inset = 10;
eps = 0.01;

hole_x = [-width / 2 + edge_inset, width / 2 - edge_inset];

difference() {
    union() {
        // 水平フランジ
        translate([-width / 2, 0, -thickness])
            cube([width, depth, thickness]);

        // 垂直フランジ
        translate([-width / 2, -thickness, 0])
            cube([width, thickness, height]);

        // コーナーの接続部
        translate([-width / 2, -thickness, -thickness])
            cube([width, thickness, thickness]);
    }

    for (x = hole_x) {
        // 水平フランジの皿穴（外側は -Z 側）
        for (y = [edge_inset, depth - edge_inset]) {
            translate([x, y, -thickness - eps])
                cylinder(h = thickness + 2 * eps, d = hole_d);

            translate([x, y, -thickness])
                cylinder(h = countersink_depth, d1 = countersink_d, d2 = hole_d);
        }

        // 垂直フランジの皿穴（外側は -Y 側）
        for (z = [edge_inset, height - edge_inset]) {
            translate([x, -thickness - eps, z])
                rotate([-90, 0, 0])
                    cylinder(h = thickness + 2 * eps, d = hole_d);

            translate([x, -thickness, z])
                rotate([-90, 0, 0])
                    cylinder(h = countersink_depth, d1 = countersink_d, d2 = hole_d);
        }
    }
}