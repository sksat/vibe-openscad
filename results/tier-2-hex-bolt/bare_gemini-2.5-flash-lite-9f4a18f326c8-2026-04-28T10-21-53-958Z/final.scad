// M8 Hex Bolt (shank only, no threads)

// Bolt dimensions
head_across_flats = 13; // Across-flats of the hex head
head_height = 5.3;     // Height of the hex head
shank_diameter = 8;    // Diameter of the shank
shank_length = 30;     // Length of the shank

// Calculate hex head radius and outer radius for minkowski
head_radius = head_across_flats / 2;
hex_outer_radius = head_radius / cos(30); // Radius to the vertex of the hexagon

// Create the hex head
module hex_head() {
    hull() {
        // Create 6 points of the hexagon at the base
        for (i = [0:6]) {
            rotate([0, 0, i * 60]) {
                translate([head_radius, 0, 0]) {
                    cylinder(h=head_height, r=0.1, center=false); // Small cylinder to define points
                }
            }
        }
    }
}

// Create the shank
module shank() {
    cylinder(h=shank_length, r=shank_diameter/2, center=false);
}

// Assemble the bolt
module m8_bolt() {
    // Place the hex head at the origin (z=0)
    // The hex_head module creates its base at z=0 by default
    hex_head();

    // Place the shank below the head, extending in the -Z direction
    // The hex head is at z=0 to head_height. The shank starts at z=0 and goes down.
    // So we need to translate the shank by head_height in the negative Z direction
    translate([0, 0, -head_height]) {
        shank();
    }
}

// Render the bolt
m8_bolt();