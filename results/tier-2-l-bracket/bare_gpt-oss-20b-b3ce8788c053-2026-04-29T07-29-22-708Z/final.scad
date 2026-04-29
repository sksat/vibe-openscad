// L‑bracket with countersunk M4 holes

module bracket() {
    // dimensions
    w = 50;          // horizontal width (X)
    d = 40;          // horizontal depth (Y)
    h = 3;           // plate thickness (Z for horizontal face)
    v = 3;           // vertical plate thickness (X)
    ht = 40;         // height of vertical plate (Z)

    eps = 0.01;      // small offset to avoid coplanar issues

    // Create the L shape
    difference() {
        union() {
            // horizontal face
            translate([0, 0, 0]) cube([w, d, h]);

            // vertical face
            translate([0, 0, 0]) cube([v, d, ht]);
        }
        // Remove the overlapping corner cube
        translate([0, 0, 0]) cube([v, d, h]);
    }

    // --------- Countersunk holes on horizontal face (XY plane) ----------
    for (x = [10, 40]) {
        // Big cone part (countersink)
        translate([x, d/2 - 0.5, 0])
            rotate([90, 0, 0])          // align along Z
                cylinder(r=4, h=2 + eps);

        // Small drill part
        translate([x, d/2 - 0.5, 0])
            rotate([90, 0, 0])
                cylinder(r=2.25, h=h + eps);
    }

    // --------- Countersunk holes on vertical face (XZ plane) ----------
    for (x = [10, 40]) {
        // Big cone part (countersink)
        translate([x, -eps, ht/2])
            rotate([0, 90, 0])          // align along Y
                cylinder(r=4, h=2 + eps);

        // Small drill part
        translate([x, -eps, ht/2])
            rotate([0, 90, 0])
                cylinder(r=2.25, h=v + eps);
    }
}

bracket();