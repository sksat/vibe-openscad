$fn = 96;

// Dimensions in mm
outer_radius = 40;
inner_radius = 35;
mug_height = 90;
bottom_thickness = 6;
handle_thickness = 14;
arc_steps = 48;

// A D-shaped outline in the X–Z plane:
// straight edge on the left, semicircular edge on the right.
module d_outline(left_x, arc_center_x, center_z, radius) {
    polygon(points = concat(
        [[left_x, center_z - radius]],
        [for (i = [0 : arc_steps])
            [arc_center_x + radius * cos(-90 + 180 * i / arc_steps),
             center_z + radius * sin(-90 + 180 * i / arc_steps)]],
        [[left_x, center_z + radius]]
    ));
}

module handle() {
    rotate([90, 0, 0])
        linear_extrude(height = handle_thickness, center = true)
            difference() {
                // The straight edge overlaps the mug wall for a solid join.
                d_outline(38, 52, 45, 25);
                // Opening: 30 mm high and 25 mm wide.
                d_outline(43, 53, 45, 15);
            }
}

union() {
    difference() {
        cylinder(h = mug_height, r = outer_radius);
        translate([0, 0, bottom_thickness])
            cylinder(h = mug_height - bottom_thickness + 1,
                     r = inner_radius);
    }

    // Handle only on the +X side.
    handle();
}