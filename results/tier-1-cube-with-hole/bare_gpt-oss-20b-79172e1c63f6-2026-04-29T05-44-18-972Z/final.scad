difference() {
    // 50 mm × 50 mm × 50 mm cube centered at the origin
    cube([50, 50, 50], center = true);

    // 20 mm diameter cylindrical hole drilled along the Z‑axis,
    // extended slightly beyond the cube for clean subtraction.
    cylinder(d = 20, h = 51, $fn = 64, center = true);
}