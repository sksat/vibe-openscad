// Mug dimensions
outer_diameter   = 80;
outer_radius     = outer_diameter / 2;  // 40 mm
height           = 100;
wall_thickness   = 4;
bottom_thickness = 6;

// Handle dimensions
handle_radius    = 12;   // ring (major) radius
handle_thickness = 4;    // cross-section (minor) radius
handle_offset    = 2;    // shifts handle axis outward for good overlap
handle_height    = height / 2;

$fn = 100;  // smoothness

module mug_body() {
    cylinder(h = height, r = outer_radius);
}

module mug_handle() {
    translate([outer_radius + handle_offset, 0, handle_height])
        rotate([0, 90, 0])
            rotate_extrude(convexity = 10)
                translate([handle_radius, 0, 0])
                    circle(r = handle_thickness);
}

difference() {
    union() {
        mug_body();
        mug_handle();
    }
    // Hollow interior
    translate([0, 0, bottom_thickness])
        cylinder(h = height - bottom_thickness,
                 r = outer_radius - wall_thickness);
}