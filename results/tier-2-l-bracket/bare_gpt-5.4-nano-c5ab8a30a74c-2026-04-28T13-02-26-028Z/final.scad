// L-bracket (OpenSCAD)
// Inner corner at origin: horizontal flange +Y, vertical flange +Z

$fn = 64;

th = 3;

w = 50;    // width (X)
d = 40;    // depth/length (Y for horizontal, Z for vertical)

hole_through = 4.5;  // clearance (M4)
countersink_d = 8;   // countersink diameter (head seat)
countersink_depth = 2;

module countersunk_m4_on_xy_surface(
    // Place hole on a surface in the XY plane (normal +Z)
    x, y,
    thickness_dir = "Zpos",  // unused (for clarity)
    plate_thickness = th
) {
    // Through hole (cyl oriented +Z)
    translate([x, y, -1])
        cylinder(h = plate_thickness + 2, d = hole_through);

    // Countersink seat on outer side (here: outer side is -Z, i.e., below the top surface)
    // For a surface whose normal is +Z, "outer side" is -Z.
    translate([x, y, plate_thickness - countersink_depth])
        cylinder(h = countersink_depth, d = countersink_d);
}

// Horizontal flange: lies in X-Y plane at Z=0..th, extends +Y
// Inner corner at origin: its corner is at (X=0..w, Y=0) and Z=0..th
// We'll center in X for symmetry: X from -w/2..+w/2
module horizontal_flange() {
    difference() {
        // Solid
        translate([-w/2, 0, 0])
            cube([w, d, th]);

        // Holes (2 holes along the centerline of each side, left-right symmetric in X)
        // Centerline along Y: y = d/2, but specified "on center line" and "10mm in from edge".
        // The "edges" refer to the X direction (left/right). So place at X = +/- (w/2 - 10)
        x1 = (w/2 - 10);
        y_center = d/2;

        // Outer side for horizontal flange: outside is the side facing -Z (bolt head side)
        // Our countersink seat should be on outer side (-Z) => we create seat from top surface downward (already done).
        // We'll add countersinks with seat on top at Z = th - depth (i.e., facing -Z).
        translate([ x1, y_center, 0 ]) {
            // Use helper with "surface normal +Z"
            countersunk_m4_on_xy_surface(0, 0);
        }
        translate([ -x1, y_center, 0 ]) {
            countersunk_m4_on_xy_surface(0, 0);
        }
    }
}

// Vertical flange: lies in X-Z plane at Y=0..??, extends +Z, attached at inner corner (Y=0)
// Place as rectangle in X-Z at Y=0..th, extends +Z to height d
module vertical_flange() {
    difference() {
        // Solid
        translate([-w/2, 0, 0])
            cube([w, th, d]);

        // Holes on this vertical face: specified "each face has 2 holes on its center line,
        // 10mm inward from the edges, left-right symmetric" -> inward refers to X edges.
        // Centerline along Z: z = d/2.
        x1 = (w/2 - 10);
        z_center = d/2;

        // For vertical flange, face normal is +Y/-Y, and "outer side" is the side where bolt head is.
        // We'll orient the countersink to face +Y (outer side), which corresponds to seating at Y = th - depth.
        // Implement by creating through hole along +Y and countersink from outer side at Y=th-depth.
        for (x = [ x1, -x1 ]) {
            translate([x, 0, z_center]) {
                // Through hole along Y
                translate([0, -1, 0])
                    rotate([0,90,0]) // rotate cylinder axis to align with Y
                        cylinder(h = th + 2, d = hole_through);

                // Countersink seat on outer side (+Y): create seat at Y = th - countersink_depth
                // Cylinder axis along Y (after rotation), positioned accordingly.
                translate([0, th - countersink_depth, 0])
                    rotate([0,90,0])
                        cylinder(h = countersink_depth + 0.01, d = countersink_d);
            }
        }
    }
}

// Build bracket: union of both flanges
union() {
    horizontal_flange();
    vertical_flange();
}