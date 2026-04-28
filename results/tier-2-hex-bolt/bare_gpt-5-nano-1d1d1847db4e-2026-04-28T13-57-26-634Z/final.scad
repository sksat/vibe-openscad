// OpenSCAD: M8 hex bolt (thread omitted), hex head + cylindrical shank

// Across-flats of hex head
D = 13; // mm

// Regular hexagon circumradius from across-flats: R = D / sqrt(3)
R = D / sqrt(3);

// 2D hexagon points (circumradius R), oriented generically
points_hex = [
    for (i = [0 : 5])
        [
            R * cos(i * 60 * PI / 180),
            R * sin(i * 60 * PI / 180)
        ]
];

// Head: hexagonal prism, thickness 5.3 mm, bottom on z = 0
module head() {
    linear_extrude(height = 5.3, center = false)
        polygon(points = points_hex);
}

// Shank: cylinder, diameter 8 mm (radius 4 mm), length 30 mm
module shank() {
    cylinder(h = 30, r = 4, center = false);
}

// Assemble: head on top (z 0 to 5.3), shank extending to z < 0 (z -30 to 0)
union() {
    head(); // z = 0 .. 5.3
    translate([0, 0, -30])
        shank(); // z = -30 .. 0
}