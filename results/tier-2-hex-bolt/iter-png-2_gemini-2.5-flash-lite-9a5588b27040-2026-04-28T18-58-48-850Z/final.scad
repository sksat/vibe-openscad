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
    // To make it extend in the -Z direction, we'll negate its height or translate it.
    cylinder(h=shank_length, r=shank_diameter/2, center=false);
}

// Assemble the bolt
module m8_bolt() {
    // Place the hex head. Its bottom face is at z=0 as per the prompt.
    hex_head();

    // Place the shank below the head.
    // The head's bottom is at z=0. The shank should start from z=0 and go downwards.
    // To achieve this, we translate the shank module's default position.
    // The shank module creates a cylinder starting at z=0 and going up.
    // We need to move it down by the height of the head and then negate its Z extent,
    // or simply translate it so its top face aligns with the head's bottom face.
    // A simpler way is to translate it by -head_height and then reverse its orientation if needed,
    // or by creating it with a negative height if OpenSCAD supported that directly for cylinder.
    // The current shank() creates a cylinder from z=0 to z=shank_length.
    // To place it below the head (which is from z=0 to z=head_height),
    // we need its top at z=0 and extend to z=-shank_length.
    // So we translate it by (0, 0, -head_height). This moves the base of the cylinder to z = -head_height.
    // The cylinder then goes from z = -head_height to z = -head_height + shank_length.
    // This is incorrect.

    // Let's re-think the placement.
    // Head is from z=0 to z=head_height.
    // Shank needs to be from z=0 downwards.
    // The shank module currently creates a cylinder from z=0 to z=shank_length.
    // We need to flip it and position its top at z=0.

    // Option 1: Create shank that extends downwards directly.
    // module shank_down() {
    //     cylinder(h=-shank_length, r=shank_diameter/2, center=false); // This would require negative height support
    // }
    // translate([0, 0, 0]) shank_down(); // This would put its top at z=0.

    // Option 2: Use translate and rotate or scale.
    // Create the shank normally (z=0 to shank_length) and then move it.
    // We want the top of the shank to be at z=0. The shank module's top is at z=shank_length.
    // So we need to move it up by shank_length, and then flip it.
    // Or, we create it and then move its base to z=0 and then flip its Z direction.

    // The simplest is to align the top of the shank with the bottom of the head.
    // The head's bottom is at z=0.
    // The shank module creates a cylinder from z=0 to z=shank_length.
    // We want the shank to go from z=0 to z=-shank_length.
    // So we need to translate the shank module by (0, 0, 0) but with a negative height, which we cannot do directly.
    // A common way is to center the cylinder and then translate.
    // If cylinder(h=..., r=..., center=true), it goes from -h/2 to +h/2.

    // Let's go back to the original intent: "shankは z<0 側へ伸ばす" and "頭部の底面が原点(z=0)に来るように配置".
    // The hex_head() call already places the head with its bottom at z=0.
    // So the shank should start at z=0 and go down.
    // The current shank() creates a cylinder from z=0 to z=shank_length.
    // We need to take this cylinder and move its top face (which is at z=shank_length) to z=0.
    // This means translating it upwards by -shank_length.
    // This is incorrect.

    // Let's try again.
    // Head: z = 0 to z = head_height.
    // Shank: Needs to be from z = 0 to z = -shank_length.

    // Current shank() makes cylinder from z=0 to z=shank_length.
    // To make it go from z=0 to z=-shank_length, we can do the following:
    // 1. Translate it up so its base is at z = shank_length.
    // 2. Then flip it along the Z axis.
    // 3. Then translate it down so its top is at z=0.

    // Let's use a more direct approach.
    // We want the top of the shank to be at z=0.
    // The shank module creates a cylinder with its base at z=0.
    // So, if we translate it by (0, 0, -shank_length), its base is at z=-shank_length and top at z=0.
    // This is correct for positioning its top at z=0.
    // However, the prompt states "シャンクは z<0 側へ伸ばす", meaning it should extend into negative Z.
    // So, the bottom of the shank should be at z=-shank_length and the top at z=0.

    // The hex_head() is called and its bottom is at z=0.
    // The shank should then start from z=0 and go to z=-shank_length.
    // The shank module currently creates a cylinder from z=0 to z=shank_length.
    // To make it go from z=0 to z=-shank_length, we need to reverse its direction.
    // One way is to create the cylinder and then rotate it 180 degrees around X or Y,
    // then translate it.

    // A simpler way is to realize that OpenSCAD's cylinder(h, r) creates from z=0 to z=h.
    // If we want it from z=0 to z=-shank_length, we can write:
    // translate([0,0,0]) {
    //     rotate([180, 0, 0]) cylinder(h=shank_length, r=shank_diameter/2, center=false);
    // }
    // This places the origin of the rotated cylinder at z=0, so it will go from z=0 down to z=-shank_length.

    // So, the shank should be placed at z=0 (origin of the rotated cylinder).
    translate([0, 0, 0]) {
        rotate([180, 0, 0]) {
            cylinder(h=shank_length, r=shank_diameter/2, center=false);
        }
    }
}

// Render the bolt
m8_bolt();