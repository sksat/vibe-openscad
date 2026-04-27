// 50mm cube with a through hole (diameter 20mm) along Z axis
difference() {
    cube([50, 50, 50], center=true);
    cylinder(h=60, d=20, center=true, $fn=100);
}