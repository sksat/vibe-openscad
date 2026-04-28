// M8 Hex Bolt (Simplified)

// Parameters
s = 13;      // Across-flats (二面幅)
k = 5.3;     // Head height (頭部高さ)
d = 8;       // Shank diameter (軸径)
l = 30;      // Shank length (軸長さ)
$fn = 64;    // Resolution

union() {
    // Head: Hexagonal prism
    // In OpenSCAD, cylinder with $fn=6 creates a polygon where 'r' is the circumradius.
    // Circumradius = (Across-flats / 2) / cos(30)
    translate([0, 0, 0])
        rotate([0, 0, 0])
        cylinder(h = k, r = (s / 2) / cos(30), $fn = 6);

    // Shank: Cylinder
    // Extending towards z < 0
    translate([0, 0, -l])
        cylinder(h = l, d = d);
}