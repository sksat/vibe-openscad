// L-bracket with countersunk holes (M4)
thickness = 3;

// Horizontal flange dimensions
horizontal_width_x = 50; // along X
horizontal_depth_y = 40; // along Y
horizontal_thickness_z = thickness; // along Z

// Vertical flange dimensions
vertical_width_x = horizontal_width_x;
vertical_height_z = 40; // along Z
vertical_thickness_y = thickness; // along Y

// Hole parameters (M4 countersunk)
hole_diameter = 4.5;
counterbore_diameter = 8;
counterbore_depth = 2;

// Position of holes: 10mm from face edges, centered in the other dimension
horizontal_hole_x = 10; // distance from left/right edge along X for horizontal flange
vertical_hole_y = 10;   // distance from front/back edge along Y for vertical flange

module l_bracket() {
    union() {
        // Horizontal flange (X x Y x Z)
        translate([0, 0, 0]) cube([horizontal_width_x, horizontal_depth_y, horizontal_thickness_z]);

        // Vertical flange (X x Y x Z)
        translate([0, 0, 0]) cube([vertical_width_x, vertical_thickness_y, vertical_height_z]);
    }
}

module countersunk_hole() {
    difference() {
        cylinder(h=100, r=hole_diameter/2);
        translate([0, 0, counterbore_depth]) 
            cylinder(h=100 - counterbore_depth, r=counterbore_diameter/2);
    }
}

l_bracket();

// Horizontal flange holes
translate([-horizontal_hole_x, horizontal_depth_y/2, horizontal_thickness_z/2])
    rotate([90, 0, 0]) countersunk_hole();
translate([horizontal_width_x + horizontal_hole_x, horizontal_depth_y/2, horizontal_thickness_z/2])
    rotate([90, 0, 0]) countersunk_hole();

// Vertical flange holes
translate([-vertical_hole_x, vertical_thickness_y/2, vertical_height_z - vertical_hole_y])
    rotate([0, 90, 90]) countersunk_hole();
translate([vertical_width_x + vertical_hole_x, vertical_thickness_y/2, vertical_height_z - vertical_hole_y])
    rotate([0, 90, 90]) countersunk_hole();