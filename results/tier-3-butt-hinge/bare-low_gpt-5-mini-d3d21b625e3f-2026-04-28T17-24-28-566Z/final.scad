// OpenSCAD: Butt hinge (小型バット蝶番) — 3 部品を 180° 開いた状態で配置
// Units: mm

// Parameters
plate_len = 30;      // Y direction (hinge axis)
plate_w = 25;        // X direction (extends outward from hinge axis)
plate_th = 2;        // Z thickness

pin_diam = 4;
pin_r = pin_diam/2;
pin_len = 32;        // includes 1mm protrusion at each end beyond knuckles

knuckle_count_total = 5;
knuckle_spacing = plate_len / (knuckle_count_total-1); // 6 mm
knuckle_positions = [-12, -6, 0, 6, 12]; // centers along Y

knuckle_od = 8;
knuckle_id = pin_diam + 0.3; // 4.6 mm
knuckle_rad_od = knuckle_od/2;
knuckle_rad_id = knuckle_id/2;

knuckle_offset_x = 4; // left knuckles center at x = -knuckle_offset_x, right at +knuckle_offset_x
knuckle_z = plate_th; // knuckle thickness in Z equals plate thickness

// Countersink (M3) parameters
csink_top_diam = 6;
csink_top_r = csink_top_diam/2;
csink_depth = 1;
csink_hole_diam = 3.2;
csink_hole_r = csink_hole_diam/2;
csink_taper_bottom_r = csink_hole_r;

// Hole layout on each plate
hole_count = 3;
hole_pitch = 8; // along Y
// place holes centered around Y=0: [-8, 0, 8]
hole_positions_y = [-hole_pitch, 0, hole_pitch];
// holes located toward the far edge of each plate (away from hinge): x = +/- plate_w/2
hole_offset_x = plate_w/2 -  (plate_w/2); // we'll compute absolute position per side

$fn = 60; // resolution

module plate_with_knuckles(side = "left") {
    // side: "left" => occupies x from -plate_w to 0 (extends to negative X)
    //       "right" => occupies x from 0 to +plate_w
    side_sign = side == "left" ? -1 : 1;
    plate_x = side_sign * plate_w;
    // Plate body: positioned so inner edge is at x=0
    translate([side_sign * plate_w/2, 0, 0]) // center plate in X and Y=0, Z=plate_th/2
        difference() {
            // main plate slab
            translate([-plate_w/2, -plate_len/2, 0])
                cube([plate_w, plate_len, plate_th], center=false);
            // subtract knuckle inner holes where knuckles belong to this plate (nothing to subtract from slab)
            // subtract countersink + through-holes
            for (py = hole_positions_y) {
                hx = side_sign * (plate_w/2 -  (plate_w*0.2)); // place holes somewhat inset from edge (20% of width)
                hy = py;
                // move coordinate to plate slab coordinate
                translate([hx, hy, 0])
                    difference() {
                        // countersink tapered frustum: from csink_top_r at top surface (z=plate_th) down to csink_taper_bottom_r at z=plate_th - csink_depth
                        translate([0,0,0])
                            union() {
                                // remove tapered frustum (carve into plate)
                                translate([0,0,0])
                                    rotate([0,0,0])
                                        translate([0,0,0])
                                            // create tapered cone by subtracting cylinder from cone-like shape
                                            // simpler: use cylinder with top radius csink_top_r and bottom radius csink_taper_bottom_r via hull of two cylinders
                                            difference() {
                                                // Make a hull between two circles to get frustum
                                                translate([0,0,plate_th])
                                                    cylinder(h=0.001, r=csink_top_r, center=false);
                                                translate([0,0,plate_th - csink_depth])
                                                    cylinder(h=0.001, r=csink_taper_bottom_r, center=false);
                                            }
                                    ;
                                // through-hole (will actually subtract below)
                            }
                        // now subtract both the frustum and the through cylinder
                        // To perform subtraction we need to place the subtracting shapes in global coordinates; we'll instead perform subtraction in parent difference by replicating here:
                    }
            }
        }
    ;
    // The above approach attempted to subtract holes inside the plate but simpler: build plate then subtract holes/knuckles via separate operations in caller.
}

// Instead we'll construct plates as unions and then subtract holes and knuckle inner bores with overall difference for each plate.

module single_plate(side = "left") {
    side_sign = side == "left" ? -1 : 1;
    // Plate slab
    plate = translate([side_sign * plate_w/2, 0, plate_th/2])
                cube([plate_w, plate_len, plate_th], center=false);
    // Knuckles (outer solid tubes) attached to slab: only on inner edge
    knuckle_centers = side == "left" ? [-12, 0, 12] : [-6, 6];
    knuckles = union();
    for (py = knuckle_centers) {
        // knuckle center at x = side_sign * (-knuckle_offset_x)? For left we want center at x = -knuckle_offset_x
        kx = side == "left" ? -knuckle_offset_x : knuckle_offset_x;
        knuckles = knuckles
            union() {
                translate([kx, py, 0])
                    // create tube by subtracting inner cylinder from outer cylinder, thickness in Z = plate_th
                    difference() {
                        // outer cylinder (make as short box then hull to cylinders to keep Z thickness)
                        translate([-knuckle_rad_od, -knuckle_rad_od, 0])
                            // center the cylinder properly: we'll create cylinder along Z
                            translate([0,0,plate_th/2])
                                cylinder(h=plate_th, r=knuckle_rad_od, center=true);
                        // subtract inner bore
                        translate([0,0,plate_th/2])
                            translate([0,0,0]) // placeholder
                                translate([0,0,0])
                                    cylinder(h=plate_th + 0.2, r=knuckle_rad_id, center=true);
                    }
            };
    }
    // countersunk holes (subtract)
    cs_subtracts = union();
    for (py = hole_positions_y) {
        hx = side_sign * (plate_w/2 - plate_w*0.15); // placed inset 15% from outer edge
        hy = py;
        // position: hole axis along Z, top at z=plate_th
        // create through cylinder for hole and tapered frustum for countersink
        // frustum: hull between two small discs
        frustum = hull() {
            translate([hx, hy, plate_th]) cylinder(h=0.001, r=csink_top_r);
            translate([hx, hy, plate_th - csink_depth]) cylinder(h=0.001, r=csink_taper_bottom_r);
        }
        cs_subtracts = cs_subtracts
            union() {
                frustum;
                translate([hx, hy, -1]) cylinder(h=plate_th+2, r=csink_hole_r, center=false);
            };
    }

    // assemble plate with knuckles, then subtract countersinks and also subtract knuckle bores that pass through to allow pin clearance
    difference() {
        union() {
            plate;
            knuckles;
        }
        // subtract countersinks and through holes
        cs_subtracts;
        // subtract inner bores through knuckles (long cylinders)
        for (py = (side=="left" ? [-12,0,12] : [-6,6])) {
            kx = side == "left" ? -knuckle_offset_x : knuckle_offset_x;
            translate([kx, py, -1]) cylinder(h=plate_th + 2, r=knuckle_rad_id, center=false);
        }
    }
}

// Pin (shaft)
module pin() {
    // centerline along Y, centered at Y=0, X=0. Extend in Y by pin_len with center at 0 -> from -pin_len/2 to +pin_len/2
    translate([0, 0, plate_th/2]) // align pin centered in Z through knuckles
        rotate([90,0,0]) // rotate so cylinder axis along Y (cylinder default along Z)
            cylinder(h=pin_len, r=pin_r, center=true);
}

// Build final assembly: left plate at x negative, right at x positive, pin at center
// Ensure plates are placed so their flat faces (Z faces) coincide in same plane (both lie in XY plane at z=0..2mm)
union() {
    // left plate
    single_plate("left");
    // right plate
    single_plate("right");
    // pin (placed through knuckles). Ensure it extends 1mm beyond knuckle ends (knuckles span 30mm along Y; pin length 32mm)
    // The pin is already centered at Y=0 with length 32mm (=> extends 1mm beyond each end).
    pin();
}