// L-bracket parameters
width = 50;
depth = 40;
thickness = 3;

// Hole parameters
hole_diameter = 4.5;
countersink_diameter = 8;
countersink_depth = 2;

// The L-bracket geometry
// Horizontal face: X=50 (width), Y=40 (depth), Z=3 (thickness)
// Vertical face: X=50 (width), Y=3 (thickness), Z=40 (height)
// They share a corner at the origin (inner corner)
bracket = union() {
    cube([width, depth, thickness]); // Horizontal plate
    cube([width, thickness, depth]); // Vertical plate
};

// Hole placement
// Centerline of width is X = 25. 
// Symmetrical positions: 25 - 10 = 15 and 25 + 10 = 35.
x_pos = [15, 35];

// Horizontal face holes (on the top surface Z=thickness)
// Placed 10mm from outer edge (Y=depth)
y_pos = depth - 10; 
horizontal_holes = [for (x = x_pos) translate([x, y_pos, thickness]) 
    difference() {
        // Countersink seat
        cylinder(d1=countersink_diameter, d2=hole_diameter, h=countersink_depth, $fn=32);
        // Through hole
        translate([0, 0, -thickness]) cylinder(d=hole_diameter, h=thickness + countersink_depth, $fn=32);
    }];

// Vertical face holes (on the side surface Y=thickness)
// Placed 10mm from outer edge (Z=depth)
z_pos = depth - 10;
vertical_holes = [for (x = x_pos) translate([x, thickness, z_pos]) 
    difference() {
        // Countersink seat (facing outward in +Y direction)
        cylinder(d1=countersink_diameter, d2=hole_diameter, h=countersink_depth, $fn=32);
        // Through hole
        translate([0, -thickness, 0]) cylinder(d=hole_diameter, h=thickness + countersink_depth, $fn=32);
    }];

// Final Assembly
difference() {
    bracket;
    // Subtract holes from the bracket
    // Note: The difference logic for the vertical face needs to account for 
    // the coordinate system. The "outward" face is Y=thickness.
    
    // Horizontal holes subtraction
    for (h = horizontal_holes) {
        translate([h[0], h[1], h[2]]) {
            // This is slightly wrong in the loop above because I used translate inside the list.
            // Let's simplify the logic for the final output.
        }
    }
}

// Corrected clean logic for final output:
module bracket_final() {
    difference() {
        union() {
            cube([width, depth, thickness]); 
            cube([width, thickness, depth]);
        }
        
        // Subtract Horizontal Holes
        for (x = x_pos) {
            translate([x, y_pos, thickness]) {
                cylinder(d1=countersink_diameter, d2=hole_diameter, h=countersink_depth, $fn=32);
                translate([0, 0, -thickness]) cylinder(d=hole_diameter, h=thickness + countersink_depth, $fn=32);
            }
        }
        
        // Subtract Vertical Holes
        for (x = x_pos) {
            translate([x, thickness, z_pos]) {
                cylinder(d1=countersink_diameter, d2=hole_diameter, h=countersink_depth, $fn=32);
                translate([0, -thickness, 0]) cylinder(d=hole_diameter, h=thickness + countersink_depth, $fn=32);
            }
        }
    }
}

bracket_final();