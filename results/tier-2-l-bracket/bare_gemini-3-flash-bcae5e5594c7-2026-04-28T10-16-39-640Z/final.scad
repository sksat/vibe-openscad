$fn = 64;

// L-bracket parameters
width = 50;
depth = 40;
height = 40;
thickness = 3;

// Hole parameters (M4 Countersunk)
hole_d = 4.5;
sink_d = 8;
sink_depth = 2;
hole_x_offset = 10; // distance from side edges

module countersunk_hole() {
    // Through hole
    cylinder(d = hole_d, h = thickness * 3, center = true);
    // Countersink (positioned to start from the surface)
    translate([0, 0, -0.01])
        cylinder(d1 = sink_d, d2 = hole_d, h = sink_depth);
}

difference() {
    // Main Body
    union() {
        // Horizontal flange (extends +Y, thickness goes to -Z)
        translate([0, 0, -thickness])
            cube([width, depth, thickness]);
        
        // Vertical flange (extends +Z, thickness goes to -Y)
        translate([0, -thickness, 0])
            cube([width, thickness, height]);
    }

    // Holes for Horizontal flange
    for (x = [hole_x_offset, width - hole_x_offset]) {
        translate([x, depth / 2, -thickness]) {
            rotate([180, 0, 0])
                countersunk_hole();
        }
    }

    // Holes for Vertical flange
    for (x = [hole_x_offset, width - hole_x_offset]) {
        translate([x, -thickness, height / 2]) {
            rotate([-90, 0, 0])
                countersunk_hole();
        }
    }
}