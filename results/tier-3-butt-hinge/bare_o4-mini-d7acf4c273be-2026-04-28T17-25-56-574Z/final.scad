// Small butt hinge in open 180° configuration

module leaf(side) {
  // side = -1 for left leaf, +1 for right leaf
  difference() {
    union() {
      // leaf plate
      translate([ side == 1 ? 0 : -25, -15, 0 ])
        cube([25, 30, 2]);
      // knuckle barrels (outer)
      for (ypt in (side == 1 ? [-6, 6] : [-12, 0, 12])) {
        translate([0, ypt, 1])
          rotate([-90, 0, 0])
            cylinder(h = 6, r = 4, center = true);
      }
    }
    // knuckle barrel inner holes
    for (ypt in (side == 1 ? [-6, 6] : [-12, 0, 12])) {
      translate([0, ypt, 1])
        rotate([-90, 0, 0])
          cylinder(h = 6, r = 2.3, center = true);
    }
    // M3 countersunk screw holes (x = ±20, y = -8,0,8)
    for (ypt = [-8, 0, 8]) {
      // countersink cone: 6mm dia → 3.2mm dia over 1mm depth
      translate([side*20, ypt, 1])
        cylinder(h = 1, r1 = 3, r2 = 1.6, center = false);
      // through hole 3.2mm dia
      translate([side*20, ypt, 0])
        cylinder(h = 1, r = 1.6, center = false);
    }
  }
}

// left leaf (x<0)
leaf(-1);
// right leaf (x>0), opened 180°
leaf(1);

// hinge pin
translate([0, 0, 1])
  rotate([-90, 0, 0])
    cylinder(h = 32, r = 2, center = true);