// Small butt hinge (furniture) - 180° open assembly

$fn = 96;

eps = 0.02;

// Dimensions
plate_len_y   = 30;   // along Y
plate_width_x = 25;   // along X (extends away from hinge axis)
plate_thick   = 2;    // along Z

kn_seg_len = 6;       // each knuckle segment length along Y
kn_od      = 8;       // knuckle outer diameter
kn_id      = 4.6;     // knuckle inner diameter (pin + 0.3 clearance)

pin_d   = 4;
pin_len = 32;         // sticks out 1mm each end (30 + 1 + 1)

hole_pitch    = 8;    // along Y
hole_y_list   = [-8, 0, 8];
hole_x_left   = -17;  // place holes on side away from knuckle (outer side)
hole_x_right  =  17;
cs_top_d      = 6;    // countersink top diameter
cs_depth      = 1;    // countersink depth
hole_thru_d   = 3.2;  // through diameter (M3 clearance)

// Knuckle Y centers (total 30mm split into 5x6mm: centers at -12, -6, 0, 6, 12)
kn_centers_left  = [-12, 0, 12];  // outer two + center one
kn_centers_right = [-6, 6];       // intermediate two

//---------------- Modules ----------------//

module pin_axis() {
  // Along +Y, centered so ends at y=±16 (knuckles at ±15)
  rotate([-90,0,0])
    cylinder(h=pin_len, r=pin_d/2, center=true);
}

module knuckle_segment(yc) {
  // A hollow cylinder segment along Y at center yc
  translate([0, yc, 0])
    rotate([-90,0,0])
      difference() {
        cylinder(h=kn_seg_len, r=kn_od/2, center=true);
        cylinder(h=kn_seg_len + 2*eps, r=kn_id/2, center=true);
      }
}

module countersunk_hole(xc, yc) {
  // Negative shape to subtract from a plate
  union() {
    // Countersink frustum: from z=(+1 - cs_depth) up to z=+1
    translate([xc, yc, 1 - cs_depth])
      cylinder(h=cs_depth, r1=hole_thru_d/2, r2=cs_top_d/2);
    // Through hole: make it longer than plate to ensure clean subtraction
    translate([xc, yc, -3])
      cylinder(h=6, r=hole_thru_d/2);
  }
}

module plate_base(side = "left") {
  // Rectangular plate: left x∈[-25,0], right x∈[0,25], y∈[-15,15], z∈[-1,1]
  if (side == "left")
    translate([-plate_width_x, -plate_len_y/2, -plate_thick/2])
      cube([plate_width_x, plate_len_y, plate_thick], center=false);
  else
    translate([0, -plate_len_y/2, -plate_thick/2])
      cube([plate_width_x, plate_len_y, plate_thick], center=false);
}

module plate_with_features(side = "left") {
  // Subtract countersunk holes and cutouts for the opposite knuckle segments
  difference() {
    plate_base(side);

    // Countersunk holes (on the far side from knuckle)
    if (side == "left")
      for (yy = hole_y_list)
        countersunk_hole(hole_x_left, yy);
    else
      for (yy = hole_y_list)
        countersunk_hole(hole_x_right, yy);

    // Cutouts to avoid interference with the opposite leaf's knuckles
    if (side == "left") {
      for (yc = kn_centers_right)
        translate([0, yc, 0])
          rotate([-90,0,0])
            cylinder(h=kn_seg_len + 2*eps, r=kn_od/2 + eps, center=true);
    } else {
      for (yc = kn_centers_left)
        translate([0, yc, 0])
          rotate([-90,0,0])
            cylinder(h=kn_seg_len + 2*eps, r=kn_od/2 + eps, center=true);
    }
  }
}

module leaf_assembly(side = "left") {
  union() {
    plate_with_features(side);
    if (side == "left") {
      for (yc = kn_centers_left)
        knuckle_segment(yc);
    } else {
      for (yc = kn_centers_right)
        knuckle_segment(yc);
    }
  }
}

//---------------- Assembly ----------------//

// Left leaf (x < 0)
color([0.7,0.7,0.75]) leaf_assembly("left");

// Right leaf (x > 0)
color([0.7,0.7,0.75]) leaf_assembly("right");

// Shared pin axis
color([0.85,0.85,0.85]) pin_axis();