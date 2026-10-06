$fn = 128;

cup_outer_diameter = 80;
cup_height = 100;
wall_thickness = 4;
bottom_thickness = 6;

handle_outer_radius = 12;
handle_ring_thickness = 4;
handle_depth = 8;

cup_outer_radius = cup_outer_diameter / 2;
cup_inner_radius = cup_outer_radius - wall_thickness;
handle_inner_radius = handle_outer_radius - handle_ring_thickness;

// 取手の穴を外周より外側に置き、取手本体を側壁に接合する。
handle_center_x = cup_outer_radius + handle_inner_radius + 1;
handle_center_z = cup_height / 2;

epsilon = 0.1;

union() {
    difference() {
        cylinder(h = cup_height, r = cup_outer_radius);

        translate([0, 0, bottom_thickness])
            cylinder(
                h = cup_height - bottom_thickness + epsilon,
                r = cup_inner_radius
            );
    }

    translate([handle_center_x, 0, handle_center_z])
        rotate([90, 0, 0])
            difference() {
                cylinder(
                    h = handle_depth,
                    r = handle_outer_radius,
                    center = true
                );

                cylinder(
                    h = handle_depth + 2 * epsilon,
                    r = handle_inner_radius,
                    center = true
                );
            }
}