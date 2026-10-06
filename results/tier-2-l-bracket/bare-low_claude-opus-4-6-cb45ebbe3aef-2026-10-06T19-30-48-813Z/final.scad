module countersunk_hole() {
    cylinder(d=4.5, h=20, center=true, $fn=32);
    translate([0, 0, -1])
        cylinder(d1=8, d2=4.5, h=2, $fn=32);
}

difference() {
    union() {
        // Horizontal flange: 50mm (X) × 40mm (Y) × 3mm (Z), extending +Y
        translate([0, 0, -3])
            cube([50, 40, 3]);
        // Vertical flange: 50mm (X) × 3mm (Y) × 40mm (Z), extending +Z
        translate([0, -3, 0])
            cube([50, 3, 40]);
    }

    // Holes in horizontal flange
    // Center line X=25, Y=10 from far edge means Y=30, and symmetric X: 25±15? 
    // "面の縁から10mm内側" on center line, "左右対称に2個"
    // Along Y center line at Y=20, placed 10mm from left/right edges: X=10, X=40
    for (x = [10, 40]) {
        translate([x, 20, 0])
            rotate([180, 0, 0])
                translate([0, 0, -0])
                    countersunk_hole_horiz();
    }

    // Holes in vertical flange
    for (x = [10, 40]) {
        translate([x, 0, 20])
            rotate([90, 0, 0])
                countersunk_hole_vert();
    }
}

module countersunk_hole_horiz() {
    // Through hole in Z, countersink on bottom (outside = -Z side)
    translate([0, 0, -3])
        cylinder(d=4.5, h=10, $fn=32);
    // Countersink on outside (bottom, z=-3)
    translate([0, 0, -3])
        cylinder(d1=8, d2=4.5, h=2, $fn=32);
}

module countersunk_hole_vert() {
    // Hole through Y thickness, countersink on outside (-Y side)
    translate([0, 0, -10])
        cylinder(d=4.5, h=20, $fn=32);
    // Countersink on outside (at -Y face, which is the far end in this orientation)
    translate([0, 0, 0])
        cylinder(d1=4.5, d2=8, h=2, $fn=32);
}