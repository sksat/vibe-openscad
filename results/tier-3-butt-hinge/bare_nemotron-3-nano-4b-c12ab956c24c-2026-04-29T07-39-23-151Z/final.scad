// Parameters
plate_w = 25;        // board width (X)
plate_thick = 2;     // board thickness (Z)
plate_len_y = 30;    // board length along Y

knuckle_outer_r = 8;                 // outer radius of knuckle tube
knuckle_inner_r = 4.6;               // inner radius (pin axis clearance)
pin_diam = 4;                        // pin diameter
pin_len = 32;                         // pin length (incl. 1mm knuckle ends)

// Knuckle Y positions (centered at X=0)
left_knuckles = [-30, -18, 0];       // left board: outer, middle, inner
right_knuckles = [6, 12];            // right board: outer, middle

// Plate geometry (rectangular prism) – centered around X=0
board_left = translate([-plate_w/2, 0, 0])
    rect([plate_len_y/2, plate_len_y/2], plate_thick)
    // subtract knuckle tubes (hollow cylinder)
    for(Y in left_knuckles) {
        subtract() cylinder(r=knuckle_outer_r+1e-6, h=30);
        add()   cylinder(r=knuckle_inner_r+1e-6, h=30);
    }
    // M3 dish holes on the outer side (X negative)
    for(Y in left_knuckles) {
        subtract() translate([-plate_w/2, Y-3, 0])
            cylinder(r=1.6, h=plate_thick);   // 3.2mm dia
    }

// Right board – mirrored X position
board_right = translate([+plate_w/2, 0, 0])
    rect([plate_len_y/2, plate_len_y/2], plate_thick)
    for(Y in right_knuckles) {
        subtract() cylinder(r=knuckle_outer_r+1e-6, h=30);
        add()   cylinder(r=knuckle_inner_r+1e-6, h=30);
    }
    // M3 dish holes on the outer side (X positive)
    for(Y in right_knuckles) {
        subtract() translate([+plate_w/2, Y-3, 0])
            cylinder(r=1.6, h=plate_thick);   // 3.2mm dia
    }

// Pin axis – shared by both boards
pin_axis = translate([0,0,0]) cylinder(d=pin_diam/2, h=pin_len);

// Assemble at 180° open (flat faces coincide in Z plane)
module butt_hinge {
    union() {
        board_left;
        board_right;
        pin_axis;                     // pins are inside the knuckles
    }
}

// Export as single part named "butt_hinge"