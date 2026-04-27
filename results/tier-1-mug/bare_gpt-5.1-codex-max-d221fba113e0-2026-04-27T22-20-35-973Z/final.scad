$fn = 100;

outer_radius = 40;
wall_thickness = 4;
height = 100;
bottom_thickness = 6;

handle_R = 12;
handle_r = 4;
handle_offset_x = outer_radius + handle_r;
handle_center_z = height / 2;

module mug() {
    difference() {
        cylinder(h = height, r = outer_radius);
        translate([0, 0, bottom_thickness])
            cylinder(h = height - bottom_thickness, r = outer_radius - wall_thickness);
    }
}

module ring_handle() {
    translate([handle_offset_x, 0, handle_center_z])
        rotate([0, 90, 0])
            rotate_extrude(angle = 360)
                translate([handle_R, 0, 0])
                    circle(r = handle_r);
}

union() {
    mug();
    ring_handle();
}