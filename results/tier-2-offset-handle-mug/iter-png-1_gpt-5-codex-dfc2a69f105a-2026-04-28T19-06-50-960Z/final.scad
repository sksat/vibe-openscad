$fn = 128;

mug_outer_radius = 40;
mug_inner_radius = 35;
mug_height = 90;
mug_bottom_thickness = 6;
inner_fudge = 0.2;

handle_inner_height = 30;
handle_inner_width = 25;
handle_wall_thickness = 6;
handle_depth = 20;
handle_overlap = 2;

module d_outline(straight_len, radius) {
    union() {
        square([straight_len, 2 * radius], center = false);
        intersection() {
            translate([straight_len, radius])
                circle(r = radius);
            translate([straight_len, 0])
                square([radius, 2 * radius], center = false);
        }
    }
}

module mug_body() {
    difference() {
        cylinder(h = mug_height, r = mug_outer_radius);
        translate([0, 0, mug_bottom_thickness])
            cylinder(h = mug_height - mug_bottom_thickness + inner_fudge, r = mug_inner_radius);
    }
}

module handle() {
    inner_radius = handle_inner_height / 2;
    outer_radius = inner_radius + handle_wall_thickness;
    straight_inner = max(0, handle_inner_width - inner_radius);
    straight_outer = straight_inner + handle_wall_thickness;

    translate([mug_outer_radius - handle_overlap, 0, mug_height / 2])
        rotate([90, 0, 0])
            linear_extrude(height = handle_depth, center = true, convexity = 10)
                translate([0, -outer_radius])
                    difference() {
                        d_outline(straight_outer, outer_radius);
                        translate([handle_wall_thickness, handle_wall_thickness])
                            d_outline(straight_inner, inner_radius);
                    };
}

union() {
    mug_body();
    handle();
}