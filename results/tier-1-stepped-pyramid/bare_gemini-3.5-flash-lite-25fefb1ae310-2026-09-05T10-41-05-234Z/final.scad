// 3段の階段状ピラミッド

module centered_cube(size) {
    translate([-size/2, -size/2, 0])
        cube([size, size, 10]);
}

// 1段目 (底辺 60mm × 60mm × 高さ 10mm)
color("red")
centered_cube(60);

// 2段目 (40mm × 40mm × 高さ 10mm)
color("green")
translate([0, 0, 10])
centered_cube(40);

// 3段目 (20mm × 20mm × 高さ 10mm)
color("blue")
translate([0, 0, 20])
centered_cube(20);