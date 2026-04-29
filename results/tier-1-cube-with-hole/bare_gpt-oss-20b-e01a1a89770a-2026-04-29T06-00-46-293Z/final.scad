// 50mm cube with a 20mm diameter through-hole along the Z-axis
difference() {
    // 50mm centered cube
    cube(50, center = true);

    // Through hole: cylinder larger than the cube height
    translate([0, 0, -25])   // extend below and above cube
        cylinder(d=20, h=100, $fn=64);
}