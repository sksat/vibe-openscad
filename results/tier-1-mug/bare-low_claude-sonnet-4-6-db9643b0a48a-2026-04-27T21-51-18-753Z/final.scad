$fn = 64;

outer_radius = 40;
height = 100;
wall = 4;
bottom = 6;

handle_radius = 12;
handle_tube = 4;
handle_center_z = height / 2;
handle_center_x = outer_radius + handle_radius;

difference() {
    union() {
        // Cup body
        cylinder(r = outer_radius, h = height);
        
        // Handle (torus)
        translate([handle_center_x, 0, handle_center_z])
            rotate([90, 0, 0])
                rotate_extrude(angle = 360)
                    translate([handle_radius, 0, 0])
                        circle(r = handle_tube);
    }
    
    // Hollow inside
    translate([0, 0, bottom])
        cylinder(r = outer_radius - wall, h = height - bottom + 1);
    
    // Cut handle interior to open the ring gap toward cup
    // (no cut needed; the torus is already a ring)
    
    // Cut the handle where it intersects the cup wall to open passage
    translate([outer_radius - wall, -handle_radius - handle_tube - 1, handle_center_z - handle_radius - handle_tube - 1])
        cube([wall + 1 + handle_tube, (handle_radius + handle_tube + 1) * 2, (handle_radius + handle_tube + 1) * 2]);
}