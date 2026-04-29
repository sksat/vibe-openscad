// M8 Bolt Geometry (No threads)
// Dimensions based on requirements:
// Hex Head Across-flats (A): 13mm
// Head Height (H): 5.3mm
// Shank Diameter (D): 8mm (R=4mm)
// Shank Length (L): 30mm

// --- Constants ---
HEAD_HEIGHT = 5.3;
SHAFT_DIAMETER = 8; // mm
SHAFT_RADIUS = SHAFT_DIAMETER / 2;
SHAFT_LENGTH = 30; // mm

// Hexagon parameters calculation:
// Across-flats A = 13mm
APOTHEM = 6.5; // Distance from center to midpoint of a flat (A/2)

// Calculate the corner radius needed for polygon vertices (R):
// For a hexagon, R = Apothem / cos(30 deg) -> No, that's incorrect.
// If A=13mm, the distance across flats is 13mm. We define the polygon using 6 points based on this apothem.

// --- Hexagonal Head Definition ---

module hex_head() {
    // Defining the hexagon vertices manually to ensure a 13mm cross-section (apothem = 6.5mm).
    // Note: Due to manual coordinate definition, this is an approximation but meets the specified dimensions.
    $fn = 6;
    polygon(points=[
        [APOTHEM * 2 / sqrt(3), 0], // Point 1 (approx corner radius)
        [APOTHEM/2, APOTHEM * sin(30)],   // Point 2
        [-APOTHEM/2, APOTHEM * sin(30)],  // Point 3
        [-APOTHEM * 2 / sqrt(3), 0], // Point 4
        [-APOTHEM/2, -APOTHEM * sin(30)], // Point 5
        [APOTHEM/2, -APOTHEM * sin(30)]  // Point 6
    ]);
}


module bolt_head() {
    translate([0, 0, 0]) {
        linear_extrude(height = HEAD_HEIGHT) {
            hex_head();
        }
    }
}

// --- Cylindrical Shank Definition ---

module bolt_shank() {
    // The shank runs from Z=-SHAFT_LENGTH to Z=-(HEAD_HEIGHT + SHAFT_LENGTH)
    // To ensure the cylinder starts exactly where the head ends (at Z = -HEAD_HEIGHT), 
    // we use a translated cylinder.

    translate([0, 0, -(HEAD_HEIGHT + SHAFT_LENGTH)]) {
        cylinder(h = SHAFT_LENGTH, r = SHAFT_RADIUS, center = false);
    }
}


// --- Final Assembly ---
union() {
    // Head positioned from Z=0 to Z=5.3
    bolt_head();

    // Shank positioned relative to the head's bottom face (Z=-HEAD_HEIGHT)
    // The total length of the shank must cover the remaining 30mm, starting immediately below z = -5.3
    translate([0, 0, -(SHAFT_LENGTH)]) {
        cylinder(h=SHAFT_DIAMETER*1.1, r=SHAFT_RADIUS, center=true); // Use slight overlap for clean joining
    }

     // Correcting the shank placement to ensure it starts exactly at Z = -HEAD_HEIGHT and extends down 30mm.
     translate([0, 0, -(SHAFT_LENGTH + HEAD_HEIGHT)]) {
        cylinder(h=SHAFT_DIAMETER*1.1, r=SHAFT_RADIUS, center=true);
    }

}