module Lbracket() {
    outer_w = 50; // width (X)
    outer_d = 40; // depth/height per plate
    t = 3;        // thickness

    // ---------- plates ----------
    // Horizontal plate: lies in X‑Y plane, extends +Y, thickness outward -Z
    h_plate = cube([outer_w, outer_d, t]);                // full solid
    translate([0,0,-t/2])
        rotateX(90)
            difference() {
                // cut interior cavity (3 mm wall) – not needed for L shape but keeps plate thin
                cylinder(d=outer_w-2*t, h=t);
                cylinder(d=outer_d-2*t, h=t);
            }
    h_plate = translate([0,0,-t/2])
        rotateX(90)
            difference() {
                cylinder(d=outer_w-2*t, h=t);
                cylinder(d=outer_d-2*t, h=t);
            }

    // Vertical plate: lies in X‑Z plane, extends +Z, thickness outward -Y
    v_plate = cube([outer_w, outer_d, t]);
    translate([0,0,t/2])
        rotateY(90)
            difference() {
                cylinder(d=outer_w-2*t, h=t);
                cylinder(d=outer_d-2*t, h=t);
            }
    
    // ---------- countersunk holes ----------
    hole_d = 8;   // Ø for the countersink seat (8 mm)
    hole_depth = 2; // depth of seat

    // Four holes per face: two on each plate, centered on its long edge,
    // 10 mm inside the outer edge and symmetrically placed.

    // Hole on horizontal plate – left side
    translate([outer_d/4 - hole_depth/2 - 10, 0, -t/2])
        difference() {
            cylinder(d=hole_d, h=hole_depth);
            // seat
            translate([0,0,-(hole_depth/2)]) cylinder(d=hole_d+2, h=hole_depth);
        }

    // Hole on horizontal plate – right side
    translate([outer_w - 10 - hole_depth/2, 0, -t/2])
        difference() {
            cylinder(d=hole_d, h=hole_depth);
            translate([0,0,-(hole_depth/2)]) cylinder(d=hole_d+2, h=hole_depth);
        }

    // Hole on vertical plate – bottom side
    translate([0, outer_w - 10 - hole_depth/2, t/2])
        difference() {
            cylinder(d=hole_d, h=hole_depth);
            translate([0,0,-hole_depth/2]) cylinder(d=hole_d+2, h=hole_depth);
        }

    // Hole on vertical plate – top side
    translate([0, outer_w - 10 - hole_depth/2, t/2 + hole_depth])
        difference() {
            cylinder(d=hole_d, h=hole_depth);
            translate([0,0,-hole_depth/2]) cylinder(d=hole_d+2, h=hole_depth);
        }
}

// Assemble L‑bracket
Lbracket();