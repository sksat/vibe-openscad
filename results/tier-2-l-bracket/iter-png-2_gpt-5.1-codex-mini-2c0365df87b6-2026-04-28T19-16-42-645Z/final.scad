$fn = 64;

thickness = 3;
flange_width = 50;
flange_depth = 40;
flange_height = 40;

through_diameter = 4.5;
countersink_diameter = 8;
countersink_depth = 2;
clearance = 1;

hole_positions = [10, flange_width - 10];

module horizontal_flange() {
    difference() {
        cube([flange_width, flange_depth, thickness]);
        for (x = hole_positions) {
            translate([x, flange_depth / 2, -clearance])
                cylinder(h = thickness + 2 * clearance, r = through_diameter / 2);

            translate([x, flange_depth / 2, thickness - countersink_depth])
                cylinder(h = countersink_depth, r = countersink_diameter / 2);
        }
    }
}

module vertical_flange() {
    difference() {
        cube([flange_width, thickness, flange_height]);
        for (x = hole_positions) {
            translate([x, -clearance, flange_height / 2])
                rotate([90, 0, 0])
                    cylinder(h = thickness + 2 * clearance, r = through_diameter / 2);

            translate([x, thickness - countersink_depth, flange_height / 2])
                rotate([90, 0, 0])
                    cylinder(h = countersink_depth, r = countersink_diameter / 2);
        }
    }
}

union() {
    horizontal_flange();
    vertical_flange();
}