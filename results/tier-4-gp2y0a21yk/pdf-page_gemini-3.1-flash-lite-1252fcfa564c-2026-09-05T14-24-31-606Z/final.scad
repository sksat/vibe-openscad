// Sharp GP2Y0A21YK0F 3D Model
// Unit: mm

$fn = 50;

module gp2y0a21yk0f() {
    // Main Body Dimensions
    body_w = 37;
    body_d = 13;
    body_h = 13.5;
    
    // Offset to center the origin
    z_offset = -1.5; 

    // Main Case
    color("DimGray")
    translate([0, 0, z_offset]) {
        cube([body_w, body_d, body_h], center = true);
    }

    // Mounting Tabs
    color("DimGray")
    translate([0, 0, -5.5 + z_offset]) {
        // Left Tab
        hull() {
            translate([-18.5 + 3.75, 0, 0]) cylinder(r = 3.75, h = 2);
            translate([-18.5, -3.75, 0]) cube([3.75, 7.5, 2]);
        }
        // Right Tab
        hull() {
            translate([18.5 - 3.75, 0, 0]) cylinder(r = 3.75, h = 2);
            translate([18.5 - 3.75, -3.75, 0]) cube([3.75, 7.5, 2]);
        }
    }

    // Mounting Holes
    color("Black")
    translate([0, 0, -8 + z_offset]) {
        translate([-14.75, 0, 0]) cylinder(r = 1.6, h = 10);
        translate([14.75, 0, 0]) cylinder(r = 1.6, h = 10);
    }

    // Lenses
    color("Black")
    translate([0, 0, 4 + z_offset]) {
        translate([-10, 0, 0]) cylinder(r = 3.5, h = 3);
        translate([10, 0, 0]) cylinder(r = 3.5, h = 3);
    }

    // Connector Block
    color("LightGray")
    translate([0, -body_d/2 - 1.65, -1.5 + z_offset]) {
        cube([10.1, 3.3, 8.4], center = true);
    }
}

// Render the model
gp2y0a21yk0f();