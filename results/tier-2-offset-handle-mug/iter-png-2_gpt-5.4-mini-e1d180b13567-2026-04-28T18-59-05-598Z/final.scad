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
    // D-shaped handle with the flat side facing the mug body
    // Built in YZ cross-section and extruded along +X
    translate([outer_d/2 - 1.0, 0, height/2 - handle_clear_h/2])
        rotate([0, 90, 0])
        linear_extrude(height = handle_depth)
        difference() {
            // outer profile: rectangle on body side + semicircle outward
            union() {
                translate([0, -(handle_clear_h/2 + handle_wall)])
                    square([handle_wall, handle_clear_h + 2*handle_wall], center = false);
                translate([handle_wall, 0])
                    circle(r = handle_clear_h/2 + handle_wall);
            }

            // inner void: 25mm wide x 30mm high
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

    // Attach handle only on the +X side, centered vertically
    translate([0.6, 0, 0])
        handle_solid();
}