$fn = 128;

outer_d = 80;
inner_d = 70;
height = 90;
bottom_thickness = 6;

handle_clear_w = 25;
handle_clear_h = 30;
handle_wall = 5;
handle_depth = 22;          // radial extent from body toward outside
handle_embed = 3;           // overlap into body for robust union

module mug_body() {
    difference() {
        cylinder(h = height, d = outer_d);
        translate([0, 0, bottom_thickness])
            cylinder(h = height - bottom_thickness + 0.1, d = inner_d);
    }
}

module handle_solid() {
    // Create a D-shaped cross section in the YZ plane and extrude along +X.
    // Flat side is toward the mug body, curved side outward.
    translate([outer_d/2 - handle_embed, 0, height/2 - handle_clear_h/2])
        rotate([0, 90, 0])
        linear_extrude(height = handle_depth)
        difference() {
            union() {
                // Outer boundary: flat-backed rectangle + semicircle
                translate([0, -(handle_clear_h/2 + handle_wall)])
                    square([handle_wall, handle_clear_h + 2*handle_wall], center = false);
                translate([handle_wall, 0])
                    circle(r = handle_clear_h/2 + handle_wall);
            }

            // Inner void: 25mm wide x 30mm high
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

    // Handle only on the +X side, centered vertically, with guaranteed overlap
    handle_solid();
}