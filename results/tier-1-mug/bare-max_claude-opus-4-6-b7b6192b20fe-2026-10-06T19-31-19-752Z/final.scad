$fn = 100;

// Mug parameters
outer_d = 80;
outer_r = outer_d / 2;
height = 100;
wall = 4;
bottom = 6;
inner_r = outer_r - wall;
inner_h = height - bottom;

// Handle parameters
handle_tube_r = 6;          // radius of the handle tube cross-section
handle_ring_r = 20;         // radius of the handle ring centre path
handle_center_z = height / 2; // vertical centre of the handle

// Cup body
difference() {
    cylinder(r = outer_r, h = height);
    translate([0, 0, bottom])
        cylinder(r = inner_r, h = inner_h + 1);
}

// Handle (torus ring, attached to the side)
translate([outer_r + handle_ring_r - handle_tube_r, 0, handle_center_z])
    rotate([0, 0, 0])
        rotate_extrude(angle = 360)
            translate([handle_ring_r, 0, 0])
                circle(r = handle_tube_r);