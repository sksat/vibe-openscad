// Butt hinge for furniture (3 parts: left plate, right plate, pin axis)
// Opened 180 degrees, plates in same plane (Y axis is hinge axis, X is opening direction, Z is plate thickness)

// Parameters (adjustable)
plate_length_Y = 30;      // along Y
plate_width_X  = 25;       // along X (opening direction)
plate_thick    = 2;        // Z thickness
knuckle_outer_D = 8;        // outer diameter of knuckle
knuckle_inner_D = 4.6;      // inner diameter (pin clearance)
knuckle_count  = 5;         // 5 knuckles along Y
knuckle_pitch  = 6;         // 6 mm between knuckles
pin_d          = 4;         // pin diameter
pin_len        = 32;        // total pin length through knuckles
// The knuckles sit around the pin along Y, centered at Y = -12, -6, 0, 6, 12

// Holes for M3 countersunk (皿穴) at each plate away from knuckles
m3_counterbore_d = 6;        // countersunk hole diameter (表面直径)
m3_counterbore_depth = 1;     // countersunk depth
m3_thru_d = 3.2;               // through hole for M3 bolt

$fn = 100;

// Helper: position left plate (x from -plate_width_X to 0)
module left_plate(){
    difference(){
        // main plate
        translate([-plate_width_X, -plate_length_Y/2, -plate_thick/2])
            cube([plate_width_X, plate_length_Y, plate_thick], center = false);

        // through hole for hinge pin at each knuckle position (4.6 mm diameter clearance hole)
        for(i=[-2,-1,0,1,2]){
            Y = i*knuckle_pitch;
            // Centerline along Y, hole through entire plate thickness
            translate([ -plate_width_X, Y - 1, 0 ])
                // Create hole partially by aligning to the plate: use a vertical cylinder along Z
                // Since plate is flat in Z, we use translate and rotate to drill perpendicularly to Z
                // We want a through hole in the plate along Z: use cylinder along Z axis
                cylinder(h = plate_thick + 0.1, d = knuckle_inner_D + 0.4, center = true);
        }

        // Knuckle sleeves (external 8 mm diameter, around the pin) on the left plate side
        // For visualization/assembly: hollow cylinders with inner hole for pin
        translate([ -plate_width_X/2, -plate_length_Y/2, -plate_thick/2 ])
            rotate([0,0,0])
            difference(){
                // Outer knuckle cylinders positioned along Y at 5 centers on left plate side
                // We'll place the left plate knuckles (3) at Y = -12, 0, 12
            }
        // We implement knuckles as cylindrical sleeves: from left plate side toward center
        // Here simply draw 3 sleeves near the plate face (visual aid)
        for(y=[-12,0,12]){
            translate([ -plate_width_X + plate_thick/2, y, 0 ])
                rotate([0,90,0])
                cylinder(h = plate_thick, d = knuckle_outer_D, center = true);
        }
    }
}

// Helper: position right plate
module right_plate(){
    difference(){
        translate([0, -plate_length_Y/2, -plate_thick/2])
            cube([plate_width_X, plate_length_Y, plate_thick], center = false);

        // pin clearance holes through right plate
        for(i=[-2,-1,0,1,2]){
            Y = i*knuckle_pitch;
            translate([0, Y, 0])
                cylinder(h = plate_thick + 0.1, d = knuckle_inner_D + 0.4, center = true);
        }

        // Knuckles on right plate: 2 knuckles at Y = -6, 6
        for(y=[-6,6]){
            translate([ plate_width_X/2, y, 0 ])
                rotate([0,90,0])
                cylinder(h = plate_thick, d = knuckle_outer_D, center = true);
        }
    }
}

// Pin axis: cylindrical rod along Y, diameter 4 mm, length 32 mm
module pin_axis(){
    // The pin should pass through both plates and knuckles
    translate([0, -pin_len/2, 0])
        cylinder(h = pin_len, d = pin_d, center = true);
}

// Knuckle sleeves (outer diameter 8 mm, inner diameter 4.6 mm) around the pin
// These are conceptual: model as a set of hollow cylinders centered on X=0, at given Y,
// with their axis along Y (coaxial with pin). Since plates are offset in X, the sleeves straddle the pin.

module knuckles_around_pin(){
    // We will place 5 knuckles along Y at X=0, with y centers as described
    // Left plate knuckles: at Y = -12, 0, 12
    // Right plate knuckles: at Y = -6, 6
    // Outer sleeve length along X-direction is plate_thick (2mm) on each side
    // For visualization, create hollow cylinders around the pin axis
    knuckle_positions = [ -12, -6, 0, 6, 12 ];
    for(i=[0:4]){
        y = knuckle_positions[i];
        // Outer sleeve centered at X=0, Y=y
        translate([0, y, 0])
            // Create hollow cylinder: outer diameter 8, inner hole 4.6, length spanning both plates
            rotate([0,90,0])
            difference(){
                cylinder(h = plate_thick*2 + 0.1, d = knuckle_outer_D, center = true);
                cylinder(h = plate_thick*2 + 0.1, d = knuckle_inner_D, center = true);
            }
    }
}

// Now assemble all parts with plates in open 180 deg configuration
// We place left and right plates in same plane when opened, i.e., rotate right plate by 180 degrees about pin axis (Y)
// Also position so that plate flat surfaces align in a single plane (Z ~ 0)

module assembly_open180(){
    // Open 180 degrees: rotate right plate around Y axis by 180° so the flat faces coincide
    // Place left plate at X<0, right plate at X>0 before rotation
    // Base plane for reference
    translate([ -plate_width_X, 0, 0 ]) {
        // Left plate
        left_plate();
    }
    // Right plate, rotated around Y axis by 180° about pin axis at X=0
    translate([ 0, 0, 0 ]) {
        rotate([0,180,0])
            right_plate();
    }
    // Pin axis centered at X=0, Y = 0 (center between plates)
    // The pin passes through both knuckles
    pin_pos_gizmo = translate([0, 0, 0])
        pin_axis();

    // Knuckle sleeves visualization for whole hinge
    knuckles_around_pin();
}

// Main
assembly_open180();