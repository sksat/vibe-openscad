// M8 Hex Bolt (shank only, no threads)

// Bolt dimensions
head_across_flats = 13; // Across-flats of the hex head
head_height = 5.3;     // Height of the hex head
shank_diameter = 8;    // Diameter of the shank
shank_length = 30;     // Length of the shank

// Calculate the radius to the vertices of the hexagon from the center
hex_radius_to_vertex = head_across_flats / 2 / cos(30);

// Create the hex head using polygon and linear_extrude
module hex_head() {
    linear_extrude(height = head_height) {
        polygon(points = [
            [hex_radius_to_vertex * cos(0), hex_radius_to_vertex * sin(0)],
            [hex_radius_to_vertex * cos(60), hex_radius_to_vertex * sin(60)],
            [hex_radius_to_vertex * cos(120), hex_radius_to_vertex * sin(120)],
            [hex_radius_to_vertex * cos(180), hex_radius_to_vertex * sin(180)],
            [hex_radius_to_vertex * cos(240), hex_radius_to_vertex * sin(240)],
            [hex_radius_to_vertex * cos(300), hex_radius_to_vertex * sin(300)]
        ]);
    }
}

// Create the shank
module shank() {
    cylinder(h=shank_length, r=shank_diameter/2, center=false);
}

// Assemble the bolt
module m8_bolt() {
    // Place the hex head at the origin (z=0)
    // The hex_head is created with its base at z=0 by default.
    hex_head();

    // Place the shank below the head, extending in the -Z direction.
    // The head's bottom face is at z=0. So the shank should start from z=0 downwards.
    translate([0, 0, -head_height]) {
        shank();
    }
}

// Render the bolt
m8_bolt();