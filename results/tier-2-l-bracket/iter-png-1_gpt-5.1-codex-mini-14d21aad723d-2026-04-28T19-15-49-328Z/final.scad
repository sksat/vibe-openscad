$fn = 64;

thickness = 3;
flange_width = 50;
flange_depth = 40;
flange_height = 40;

through_diameter = 4.5;
countersink_diameter = 8;
countersink_depth = 2;
through_length = thickness + 6;

horizontal_center = flange_depth / 2;
vertical_center = flange_height / 2;
hole_positions = [10, flange_width - 10];

difference() {
    union() {
        cube([flange_width, flange_depth, thickness]);
        cube([flange_width, thickness, flange_height]);
    }

    for (x = hole_positions) {
        translate([x, horizontal_center, thickness / 2])
            cylinder(h = through_length, r = through_diameter / 2, center = true);

        translate([x, horizontal_center, thickness - countersink_depth / 2])
            cylinder(h = countersink_depth, r = countersink_diameter / 2, center = true);

        translate([x, thickness / 2, vertical_center])
            rotate([-90, 0, 0])
                cylinder(h = through_length, r = through_diameter / 2, center = true);

        translate([x, thickness - countersink_depth / 2, vertical_center])
            rotate([-90, 0, 0])
                cylinder(h = countersink_depth, r = countersink_diameter / 2, center = true);
    }
}