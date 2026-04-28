$fn = 64;

EPS = 0.01;

// Plate
plateX = 25;      // open/close direction
plateY = 30;      // along pin axis
plateT = 2;       // thickness
xHalf  = plateX/2;
zMid   = plateT/2;

// Hinge pin
pinD = 4;
pinL = 32;

// Knuckle
knOD = 8;
knID = pinD + 0.3; // clearance
knLen = 6;          // each segment length
knYLeft  = [-12, 0, 12]; // 3 knuckles (outer + middle)
knYRight = [-6, 6];      // 2 knuckles (interleaving)

// Screw holes
holeThroughD = 3.2;
holeCsD      = 6;
holeCsR      = holeCsD/2;
holeCsDepth  = 1;
holePitch    = 8;
holeInset    = 5; // from the far edge

module tubeSegment(od, id, lenY) {
  rotate([90, 0, 0]) {
    difference() {
      cylinder(d=od, h=lenY, center=true);
      cylinder(d=id, h=lenY + 0.02, center=true);
    }
  }
}

module knuckle(side, yCenter) {
  // Keep knuckle only on the leaf side (x<0 for left, x>0 for right)
  intersection() {
    translate([0, yCenter, zMid]) tubeSegment(knOD, knID, knLen);

    // Large clipping half-space
    if (side < 0) {
      // x <= -EPS
      translate([-100, -100, -100]) cube([100 - EPS, 200, 200], center=false);
    } else {
      // x >= +EPS
      translate([EPS, -100, -100]) cube([100, 200, 200], center=false);
    }
  }
}

module countersunkHole(x, y) {
  // countersink cone from top surface (z = plateT) down by holeCsDepth
  translate([x, y, plateT - holeCsDepth])
    cylinder(h=holeCsDepth, r1=0, r2=holeCsR, center=false);

  // through hole
  translate([x, y, -1])
    cylinder(h=plateT + 2, d=holeThroughD, center=false);
}

module leaf(side) {
  knY = (side < 0) ? knYLeft : knYRight;
  xPlateCenter = side * xHalf;
  xHole = side * (plateX - holeInset);

  difference() {
    union() {
      // Flat leaf plate
      translate([xPlateCenter, 0, zMid])
        cube([plateX, plateY, plateT], center=true);

      // Knuckles
      for (yCenter = knY)
        knuckle(side, yCenter);
    }

    // 3x M3 countersunk holes (y: -8, 0, +8)
    for (i = [-1, 0, 1]) {
      countersunkHole(xHole, i * holePitch);
    }
  }
}

// Assembled open state (180°): left leaf at x<0, right leaf at x>0, pin along +Y
union() {
  color([0.75, 0.75, 0.75]) leaf(-1); // left
  color([0.70, 0.70, 0.70]) leaf(1);  // right

  color([0.95, 0.55, 0.15]) {          // pin axis
    translate([0, 0, zMid])
      rotate([90, 0, 0])
        cylinder(d=pinD, h=pinL, center=true);
  }
}