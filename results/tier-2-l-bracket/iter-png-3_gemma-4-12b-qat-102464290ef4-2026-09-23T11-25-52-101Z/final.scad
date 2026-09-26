// L-bracket parameters
width = 50;
depth = 40;
height = 40;
thickness = 3;

// Hole parameters
hole_diameter = 4.5;
countersink_diameter = 8;
countersink_depth = 2;

// Final assembly
difference() {
    // Bracket geometry
    union() {
        // Horizontal plate: occupies X [0,50], Y [0,40], Z [0,3]
        // The large face is the top surface (XY plane at Z=thickness)
        cube([width, depth, thickness]);
        
        // Vertical plate: occupies X [0,50], Y [0,3], Z [0,40]
        // The large face is the front surface (XZ plane at Y=0)
        cube([width, thickness, height]);
    }

    // Holes on the Horizontal face (Top surface: Z = thickness)
    // Center line of Depth (Y) is depth / 2 = 20
    // Symmetrical X positions: 10mm and (width - 10) = 40mm
    for (x = [10, width - 10]) {
        translate([x, depth / 2, thickness]) {
            // Countersink seat (pointing outward in +Z direction)
            cylinder(d1=countersink_diameter, d2=hole_diameter, h=countersink_depth, $fn=32);
            // Through hole (inward in -Z direction)
            translate([0, 0, -thickness]) 
                cylinder(d=hole_diameter, h=thickness + 1, $fn=32);
        }
    }

    // Holes on the Vertical face (Front surface: Y = 0)
    // Center line of Height (Z) is height / 2 = 20
    // Symmetrical X positions: 10mm and (width - 10) = 40mm
    for (x = [10, width - 10]) {
        translate([x, 0, height / 2]) {
            // Countersink seat (pointing outward in -Y direction)
            translate([0, -countersink_depth, 0])
                cylinder(d1=countersink_diameter, d2=hole_diameter, h=countersink_depth, $fn=32);
            // Through hole (inward in +Y direction)
            translate([0, 0, -thickness]) 
                cylinder(d=hole_diameter, h=thickness + 1, $fn=32);
        }
    }
}