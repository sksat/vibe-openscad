$fn = 160;

outer_radius = 40;
inner_radius = 35;
mug_height = 90;
bottom_thickness = 6;

inner_gap_width = 25;
inner_gap_height = 30;
handle_wall_thickness = 6;
handle_depth = 16;

handle_height = inner_gap_height + 2 * handle_wall_thickness;

module mug_body() {
    difference() {
        cylinder(r = outer_radius, h = mug_height, center = false);
        translate([0, 0, bottom_thickness])
            cylinder(r = inner_radius, h = mug_height - bottom_thickness, center = false);
    }
}

module handle_cross_section() {
    intersection() {
        union() {
            translate([0, -handle_height / 2])
                square([inner_gap_width + handle_wall_thickness, handle_height], center = false);
            translate([inner_gap_width + handle_wall_thickness, 0])
                circle(r = handle_height / 2);
        }
        translate([0, -handle_height / 2])
            square(
                [inner_gap_width + handle_wall_thickness + handle_height / 2, handle_height],
                center = false
            );
    }
}

module handle_shape() {
    difference() {
        linear_extrude(height = handle_depth, center = true)
            handle_cross_section();
        translate([inner_gap_width / 2, 0, 0])
            cube([inner_gap_width, inner_gap_height, handle_depth + 4], center = true);
    }
}

module handle_body() {
    translate([outer_radius - 2, 0, mug_height / 2])
        rotate([90, 0, 0])
            handle_shape();
}

union() {
    mug_body();
    handle_body();
}