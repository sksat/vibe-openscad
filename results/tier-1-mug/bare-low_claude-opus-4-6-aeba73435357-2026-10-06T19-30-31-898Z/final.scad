difference() {
    cylinder(h=100, d=80, $fn=100);
    translate([0,0,6])
        cylinder(h=95, d=72, $fn=100);
}

// Handle
translate([40, 0, 50])
rotate([0,90,0])
difference() {
    cylinder(h=8, r=20, center=true, $fn=80);
    cylinder(h=10, r=12, center=true, $fn=80);
}