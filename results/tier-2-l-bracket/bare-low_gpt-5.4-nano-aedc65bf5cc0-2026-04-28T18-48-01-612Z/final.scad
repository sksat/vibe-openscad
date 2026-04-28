$fn = 64;

// L-bracket parameters
w = 50;   // width (X)
d = 40;   // depth for horizontal / height for vertical (Y/Z extent)
t = 3;    // plate thickness

// M4 countersunk hole parameters
through_d = 4.5;     // clearance hole diameter
seat_d = 8;          // countersink (seat) diameter
seat_depth = 2;     // countersink seat depth

// Placement: inner corner at origin
// Horizontal flange: +Y direction
// Vertical flange:   +Z direction
// Centerline: X is centered, positions are +/- along X (left/right symmetric)
// "縁から 10mm 内側" => along Y for horizontal and along Z for vertical
x_half = w/2;
y_in = 10;  // inner offset from edge for horizontal holes (along +Y)
z_in = 10;  // inner offset from edge for vertical holes (along +Z)

// Two holes per face, centerline on face, left/right symmetric
hole_x1 = -x_half/2;
hole_x2 =  x_half/2;

// Simple countersunk hole (axis along local Z of the plate):
// - through hole
// - countersunk seat on the outer side (top side for horizontal, +X side for vertical)
module m4_countersunk(orient="top") {
    // orient determines which side the countersink opens to.
    // For horizontal plate, we drill from +Z side so seat is on outer (top).
    // For vertical plate, we drill from -X side / +X side accordingly.
    if (orient == "top") {
        // seat at z = thickness
        union() {
            // Through hole
            cylinder(h=t+10, d=through_d, center=false);
            // Seat (subtracted)
            translate([0,0,t-seat_depth])
                cylinder(h=seat_depth+0.01, d=seat_d, center=false);
        }
    } else if (orient == "bottom") {
        // seat at z = 0
        union() {
            cylinder(h=t+10, d=through_d, center=false);
            translate([0,0,0])
                cylinder(h=seat_depth+0.01, d=seat_d, center=false);
        }
    } else {
        // generic (fallback): top
        union() {
            cylinder(h=t+10, d=through_d, center=false);
            translate([0,0,t-seat_depth])
                cylinder(h=seat_depth+0.01, d=seat_d, center=false);
        }
    }
}

// Build plates
difference() {
    // Solid L-bracket (union)
    union() {
        // Horizontal flange: X=[-w/2, w/2], Y=[0, d], Z=[0, t]
        translate([0, d/2, t/2])
            cube([w, d, t], center=true);

        // Vertical flange:   X=[-w/2, w/2], Y=[0, t], Z=[0, d]
        // Positioned so that inner corner is at origin (X centered, Y=0 corner).
        translate([0, t/2, d/2])
            cube([w, t, d], center=true);
    }

    // Subtract countersunk holes
    // 1) Horizontal face (+Z outer side): seat should face outer side (+Z)
    // Holes are on the centerline along the face (X), 10mm from Y edges.
    for (xpos = [hole_x1, hole_x2]) {
        // Centerline on the face: Y is "10mm inward" from the edge (Y=0 edge)
        // Keep them symmetric left/right by xpos
        translate([xpos, y_in, t/2])
            // Drill axis along Z
            rotate([0,0,0]) {
                // Subtract countersunk hole with seat toward +Z
                // Create hole geometry locally spanning beyond the solid
                // (We align so that Z=0 is top of the local subtraction in the module)
                translate([0,0,-(t/2)])
                    m4_countersunk("top");
            }
    }

    // 2) Vertical face (+Z inner side? seat toward outer bolt-head side = -X? +X?)
    // Requirement: "皿座面は外側(ボルト頭が当たる側)に向ける"
    // For vertical flange, outer side is taken as +X (the side opposite the horizontal plate interior).
    // We'll open the countersink to +X by drilling from -X toward +X.
    // Holes are on centerline of the vertical face: Z direction is "10mm inward" from edge (Z=0).
    for (xpos = [hole_x1, hole_x2]) {
        translate([xpos, t/2, z_in]) {
            // Drill axis along X, seat toward +X.
            // Create a countersunk hole with its "top" seat along +local Z; rotate to align X.
            // Local: hole axis along Z. We'll rotate so Z -> X.
            rotate([0, -90, 0])
                // seat "top" should face +X after rotation
                m4_countersunk("top");
        }
    }

    // Note: horizontal plate edge "縁から10mm内側,左右対称に2個"
    // With our positioning, Y offset is fixed (10mm from inner corner along +Y),
    // and X offset gives left/right symmetry.
    // For vertical plate, similarly we use Z offset = 10mm from inner corner along +Z.
}