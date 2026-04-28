// Small furniture butt hinge (opened 180°)
// Dimensions per spec

// Global parameters
plate_len_y = 30;          // along hinge axis (Y)
plate_len_x = 25;          // extends away from axis (X)
plate_th   = 2;            // thickness (Z)

pin_d      = 4;
pin_r      = pin_d/2;
pin_len    = 32;           // protrudes 1 mm each end beyond 30 mm knuckle stack

knuckle_outer_d = 8;
knuckle_outer_r = knuckle_outer_d/2;
knuckle_inner_d = pin_d + 0.6; // 0.3 mm clearance all around -> +0.6 mm diameter
knuckle_h   = 6;           // segment height along Y
knuckle_pos = [-12, -6, 0, 6, 12]; // centers over 30 mm, 5 equal segments

// Screw holes (countersunk) per leaf
hole_pitch_y = 8;                  // along Y
hole_centers_y = [-hole_pitch_y, 0, hole_pitch_y];
drill_d   = 3.2;
drill_r   = drill_d/2;
csk_top_d = 6;
csk_top_r = csk_top_d/2;
csk_depth = 1;

// Utilities
module cyl_y(d=1,h=1,center=true){
  // Cylinder oriented along Y axis
  rotate([90,0,0]) cylinder(d=d, h=h, center=center, $fn=64);
}

module cone_y(d1=1,d2=1,h=1,center=true){
  // Conical frustum along Y axis
  rotate([90,0,0]) cylinder(d1=d1, d2=d2, h=h, center=center, $fn=64);
}

module knuckle_segment(yc=0){
  // One hollow knuckle ring segment centered at [0,yc,1]
  translate([0,yc,plate_th/2])
  difference(){
    cyl_y(d=knuckle_outer_d, h=knuckle_h, center=true);
    cyl_y(d=knuckle_inner_d, h=knuckle_h+0.2, center=true);
  }
}

module leaf_plate(side="left"){
  // Base plate 30 (Y) x 25 (X) x 2 (Z), positioned from y=-15..+15, z=0..2
  // Left occupies x in [-25..0], Right in [0..25]
  translate([ (side=="left") ? -plate_len_x : 0,
              -plate_len_y/2,
              0])
    cube([plate_len_x, plate_len_y, plate_th], center=false);
}

module countersunk_holes(side="left"){
  // Create countersunk through holes (to subtract) at 3 positions along Y
  for(yc = hole_centers_y){
    // Hole X position centered within leaf width
    xh = (side=="left") ? -plate_len_x/2 : plate_len_x/2;
    // Through hole (Z)
    translate([xh, yc, 0])
      cylinder(d=drill_d, h=plate_th+0.2, center=false, $fn=48);
    // Countersink from top surface (z=2 down by 1 mm), conical 6 mm -> 3.2 mm
    // Implemented as a cone in Z
    translate([xh, yc, plate_th - csk_depth])
      cylinder(h=csk_depth, r1=drill_r, r2=csk_top_r, center=false, $fn=48);
  }
}

module leaf(side="left"){
  // Assemble plate + own knuckles, subtract holes and relief for opposite knuckles
  own_idx   = (side=="left") ? [0,2,4] : [1,3];
  other_idx = (side=="left") ? [1,3]   : [0,2,4];

  difference(){
    // Union: plate + own knuckles
    union(){
      leaf_plate(side);
      for(i = own_idx){
        knuckle_segment(knuckle_pos[i]);
      }
    }
    // Countersunk holes
    countersunk_holes(side);

    // Relief notches for the opposite leaf's knuckles to avoid interpenetration:
    // subtract the cylindrical envelope of the other knuckle segments
    for(i = other_idx){
      translate([0, knuckle_pos[i], plate_th/2])
        cyl_y(d=knuckle_outer_d, h=knuckle_h+0.2, center=true);
    }
  }
}

module pin(){
  // Pin along Y, centered at y=0, z=1; length 32 mm (protrudes 1 mm each end)
  translate([0, 0, plate_th/2])
    cyl_y(d=pin_d, h=pin_len, center=true);
}

// Final assembly: opened 180°, leaves coplanar with flat faces in same Z plane
union(){
  leaf("left");   // extends to x<0
  leaf("right");  // extends to x>0
  pin();          // shared pin axis along Y
}