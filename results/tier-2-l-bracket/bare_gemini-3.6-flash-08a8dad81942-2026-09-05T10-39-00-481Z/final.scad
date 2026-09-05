// L-bracket parameters
width = 50;
depth = 40;
height = 40;
thickness = 3;

// Hole parameters
hole_d = 4.5;
cs_d = 8.0;
cs_depth = 2.0;
edge_margin = 10;

$fn = 60;

module countersunk_hole() {
    translate([0, 0, -1])
        cylinder(h = thickness + 2, d = hole_d);
    translate([0, 0, -0.01])
        cylinder(h = cs_depth + 0.01, d1 = cs_d, d2 = hole_d);
}

difference() {
    // Main L-bracket body
    union() {
        // Horizontal flange (+Y direction, thickness extending -Z)
        translate([-width/2, 0, -thickness])
            cube([width, depth, thickness]);
        
        // Vertical flange (+Z direction, thickness extending -Y)
        translate([-width/2, -thickness, 0])
            cube([width, thickness, height]);
    }

    // Holes in horizontal flange
    translate([-width/2 + edge_margin, depth/2, -thickness])
        countersunk_hole();
    translate([width/2 - edge_margin, depth/2, -thickness])
        countersunk_hole();

    // Holes in vertical flange
    translate([-width/2 + edge_margin, -thickness, height/2])
        rotate([-90, 0, 0])
            countersunk_hole();
    translate([width/2 - edge_margin, -thickness, height/2])
        rotate([-90, 0, 0])
            countersunk_hole();
}