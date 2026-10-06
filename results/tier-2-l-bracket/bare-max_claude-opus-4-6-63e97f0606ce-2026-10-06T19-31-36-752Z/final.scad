// L-bracket parameters
width = 50;        // X direction
flange = 40;       // flange length (Y for horizontal, Z for vertical)
thickness = 3;     // plate thickness

// Countersunk hole parameters
hole_d = 4.5;      // through hole diameter for M4
csink_d = 8;       // countersink diameter
csink_depth = 2;   // countersink depth

// Hole positions
hole_inset = 10;   // distance from edge of flange
hole_x1 = width / 2 - hole_inset;  // symmetric X positions
hole_x2 = -(width / 2 - hole_inset);

module countersunk_hole(h, hole_dia, csink_dia, csink_dep) {
    // Through hole
    cylinder(d = hole_dia, h = h + 0.2, center = false, $fn = 32);
    // Countersink (at top)
    translate([0, 0, h - csink_dep])
        cylinder(d1 = hole_dia, d2 = csink_dia, h = csink_dep + 0.1, $fn = 32);
}

difference() {
    union() {
        // Horizontal flange: extends in +Y direction, sits on Z=0 plane
        // X: centered on 0, Y: 0 to flange, Z: -thickness to 0
        translate([-width/2, 0, -thickness])
            cube([width, flange, thickness]);

        // Vertical flange: extends in +Z direction
        // X: centered on 0, Y: -thickness to 0, Z: 0 to flange
        translate([-width/2, -thickness, 0])
            cube([width, thickness, flange]);
    }

    // --- Horizontal flange holes ---
    // Holes at Y = hole_inset from far edge => Y = flange - hole_inset
    // Countersink on bottom (outside = -Z side), bolt head sits on bottom
    // Hole goes from Z = -thickness to Z = 0
    // We model hole from bottom up: origin at Z = -thickness - 0.1
    for (hx = [hole_x1, hole_x2]) {
        translate([hx, flange - hole_inset, -thickness - 0.1]) {
            // Through hole
            cylinder(d = hole_d, h = thickness + 0.2, $fn = 32);
        }
        // Countersink at bottom (Z = -thickness side, outside)
        translate([hx, flange - hole_inset, -thickness - 0.1]) {
            cylinder(d1 = csink_d, d2 = hole_d, h = csink_depth, $fn = 32);
        }
    }

    // --- Vertical flange holes ---
    // Holes at Z = flange - hole_inset from top edge
    // Countersink on outside = -Y side (at Y = -thickness)
    // Flange goes from Y = -thickness to Y = 0
    for (hx = [hole_x1, hole_x2]) {
        translate([hx, -thickness - 0.1, flange - hole_inset]) {
            rotate([-90, 0, 0]) {
                // Through hole (along +Y after rotation means original -Z)
                // After rotate -90 about X: new Y direction = original Z
                // We need hole along Y axis (through the vertical plate)
                // rotate [-90,0,0] maps Z->Y
                cylinder(d = hole_d, h = thickness + 0.2, $fn = 32);
            }
        }
        // Countersink on -Y side (outside)
        translate([hx, -thickness - 0.1, flange - hole_inset]) {
            rotate([-90, 0, 0]) {
                cylinder(d1 = csink_d, d2 = hole_d, h = csink_depth, $fn = 32);
            }
        }
    }
}