// M8 Hex Bolt (shank only, no threads)

// Bolt dimensions
head_across_flats = 13; // Across-flats of the hex head
head_height = 5.3;     // Height of the hex head
shank_diameter = 8;    // Diameter of the shank
shank_length = 30;     // Length of the shank

// Calculate the radius to the vertices of the hexagon from the center
// The distance from the center to the midpoint of a side (apothem) is
// half the across-flats distance. The distance to a vertex is
// apothem / cos(30 degrees).
hex_radius_to_vertex = (head_across_flats / 2) / cos(30);

// Create the hex head using polygon and linear_extrude
module hex_head() {
    // The polygon is defined in the XY plane, and linear_extrude extrudes it along Z.
    // By default, the extrusion starts from z=0 and goes up.
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
    // The cylinder is created with its base at z=0 and extends upwards.
    // To make it extend in the -Z direction from z=0, we rotate it 180 degrees around the X axis.
    // This makes the "top" (originally at h) be at z=0, and the "bottom" (originally at z=0) be at z=-h.
    translate([0, 0, 0]) { // Align the top of the rotated cylinder with z=0
        rotate([180, 0, 0]) {
            cylinder(h=shank_length, r=shank_diameter/2, center=false);
        }
    }
}

// Assemble the bolt
module m8_bolt() {
    // Place the hex head. Its bottom face is at z=0 as per the prompt.
    hex_head();

    // Place the shank below the head.
    // The shank module is designed to extend in the -Z direction from z=0.
    shank();
}

// Render the bolt
m8_bolt();