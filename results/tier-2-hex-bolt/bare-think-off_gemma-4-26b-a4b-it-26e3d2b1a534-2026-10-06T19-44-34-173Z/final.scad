// M8 Bolt (Simplified)
// Dimensions:
// Head: Hexagonal, across-flats 13mm, height 5.3mm
// Shank: Diameter 8mm, length 30mm

$fn = 50; // Smoothness for cylinders

// Parameters
head_across_flats = 13;
head_height = 5.3;
shank_diameter = 8;
shank_length = 30;

// Calculate circumradius for the hexagon based on across-flats distance
// circumradius = (across_flats / 2) / cos(30)
hex_radius = (head_across_flats / 2) / cos(30);

module m8_bolt() {
    // Head: Positioned at z=0, extending to z=5.3
    translate([0, 0, 0])
    cylinder(h = head_height, r = hex_radius, $fn = 6);

    // Shank: Positioned with bottom at z=0, extending to z=-30
    translate([0, 0, -shank_length])
    cylinder(h = shank_length, d = shank_diameter);
}

// Rotate or reorient if needed, but following prompt:
// "Head bottom at origin, shank extends to z < 0"
// To align with "center axis is +Z direction" while "shank is z < 0",
// we must interpret that the bolt axis is the Z axis, but the geometry
// placement is as requested.
// The prompt says: "Center axis is +Z direction" AND "Shank is z < 0".
// This implies the bolt points "down" relative to the head.

// Since the prompt asks for the Shank to be z < 0 and Head bottom at z=0:
// The axial direction of the bolt (from head to tip) is -Z.
// To make the "axis" +Z, we can rotate the whole object 180 deg, 
// but the prompt specifically dictates the Z coordinates.
// I will follow the specific coordinate instructions.

m8_bolt();