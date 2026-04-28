$fn = 128;

outer_d = 80;
inner_d = 70;
height = 90;
bottom_thickness = 6;

handle_clear_w = 25;
handle_clear_h = 30;
handle_wall = 5;
handle_depth = 18;

module mug_body() {
    difference() {
        cylinder(h = height, d = outer_d);
        translate([0, 0, bottom_thickness])
            cylinder(h = height - bottom_thickness + 0.1, d = inner_d);
    }
}

module handle_solid() {
    // D-shaped handle opening toward the mug body (-X side)
    // Built so the flat side can overlap the mug outer wall.
    translate([outer_d/2 - 0.8, 0, height/2 - handle_clear_h/2])
    rotate([0, 90, 0])
    linear_extrude(height = handle_depth)
    difference() {
        // outer profile
        union() {
            translate([0, -(handle_clear_h/2 + handle_wall)])
                square([handle_wall, handle_clear_h + 2*handle_wall], center = false);
            translate([handle_wall, 0])
                circle(r = handle_clear_h/2 + handle_wall);
        }

        // inner void
        union() {
            translate([0, -handle_clear_h/2])
                square([handle_wall + 0.2, handle_clear_h], center = false);
            translate([handle_wall, 0])
                circle(r = handle_clear_h/2);
        }
    }
}

union() {
    mug_body();

    // Place the handle at the mid-height and attach only on +X side
    // Slight overlap ensures a manifold union without gaps.
    translate([0.5, 0, 0])
        handle_solid();
}