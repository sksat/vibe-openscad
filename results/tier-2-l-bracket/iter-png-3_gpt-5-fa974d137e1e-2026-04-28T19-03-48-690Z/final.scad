// L-bracket with counterbored M4 holes
// Dimensions
w = 50;      // width (X)
d = 40;      // depth of horizontal flange (Y)
h = 40;      // height of vertical flange (Z)
t = 3;       // thickness

// Holes
dh = 4.5;    // through hole diameter
ds = 8;      // counterbore diameter
sd = 2;      // counterbore depth
edge_x = 10; // X margin from side edges (left/right)
row = 10;    // distance from outer edge of each face (Y/Z) toward inside

$fn = 64;

difference() {
  // L-bracket body: inner corner at origin, horizontal +Y, vertical +Z
  union() {
    // Horizontal flange: X=w, Y=d, Z=t
    cube([w, d, t], center=false);
    // Vertical flange: X=w, Y=t, Z=h
    cube([w, t, h], center=false);
  }

  // Horizontal flange holes (axis along Z), counterbore from top (+Z)
  // Row located 10 mm from the outer Y edge (y = d - row)
  for (x = [edge_x, w - edge_x]) {
    // Through hole
    translate([x, d - row, -1])
      cylinder(h = t + 2, d = dh);
    // Counterbore from top face
    translate([x, d - row, t - sd])
      cylinder(h = sd, d = ds);
  }

  // Vertical flange holes (axis along Y), counterbore from outside face (+Y)
  // Row located 10 mm from the outer Z edge (z = h - row)
  for (x = [edge_x, w - edge_x]) {
    // Through hole
    translate([x, t/2, h - row])
      rotate([90, 0, 0])
        cylinder(h = t + 6, d = dh, center=true);
    // Counterbore from outside face at Y = +t, depth sd toward -Y
    translate([x, t - sd, h - row])
      rotate([90, 0, 0])
        cylinder(h = sd, d = ds, center=false);
  }
}