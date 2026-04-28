// L-bracket with counterbored holes
$fn = 64;

w = 50;          // width (X)
d = 40;          // depth of horizontal flange (Y)
h = 40;          // height of vertical flange (Z)
t = 3;           // thickness

hole_d = 4.5;    // through hole diameter
cbore_d = 8;     // counterbore diameter
cbore_h = 2;     // counterbore depth

side_offset = 10; // hole offset from side edges (X)
eps = 0.01;

module l_bracket() {
  difference() {
    // Solid L shape
    union() {
      // Horizontal flange (extends +Y, thickness along +Z)
      cube([w, d, t], center = false);
      // Vertical flange (extends +Z, thickness along +Y)
      cube([w, t, h], center = false);
    }

    // Holes in horizontal flange (axis along Z), counterbore on outer face (z = t)
    for (xpos = [side_offset, w - side_offset]) {
      translate([xpos, d/2, -eps]) cylinder(h = t + 2*eps, d = hole_d);
      translate([xpos, d/2, t - cbore_h]) cylinder(h = cbore_h, d = cbore_d);
    }

    // Holes in vertical flange (axis along Y), counterbore on outer face (y = t)
    for (xpos = [side_offset, w - side_offset]) {
      translate([xpos, -eps, h/2]) rotate([-90, 0, 0]) cylinder(h = t + 2*eps, d = hole_d);
      translate([xpos, t - cbore_h, h/2]) rotate([-90, 0, 0]) cylinder(h = cbore_h, d = cbore_d);
    }
  }
}

l_bracket();