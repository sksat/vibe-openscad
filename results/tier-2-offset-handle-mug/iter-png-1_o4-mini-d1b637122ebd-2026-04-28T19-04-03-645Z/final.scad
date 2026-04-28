// mug with D‐shaped handle on +X side
outer_d        = 80;   // outer diameter of mug
inner_d        = 70;   // inner diameter of mug
height         = 90;   // total mug height
bottom_thick   = 6;    // bottom thickness
open_w         = 25;   // finger‐hole width
open_h         = 30;   // finger‐hole height
h_thick        = 15;   // handle wall thickness (radius of outer arc)
$fn            = 100;  // resolution

module mug() {
  difference() {
    // outer shell
    cylinder(d = outer_d, h = height, $fn = $fn);
    // hollow interior
    translate([0,0,bottom_thick])
      cylinder(d = inner_d, h = height - bottom_thick, $fn = $fn);
  }
}

module handle2d() {
  // 2D profile of the D‐shape (in the X–Y plane)
  inner_x      = outer_d/2;           // flat‐face at mug outer
  arc_cx       = inner_x + open_w;    // center of semicircle
  union() {
    // rectangular segment from flat face to start of arc
    translate([inner_x, -h_thick])
      square([open_w, 2*h_thick], center = false);
    // outer semicircle (right half of a full circle)
    intersection() {
      translate([arc_cx, 0])
        circle(r = h_thick, $fn = $fn);
      // clip to x >= arc_cx (to keep only the right half)
      translate([arc_cx, -100])
        square([h_thick, 200], center = false);
    }
  }
}

module handle() {
  // place handle at mid‐height, extrude the 2D D‐profile by open_h
  translate([0, 0, height/2 - open_h/2])
    linear_extrude(height = open_h)
      handle2d();
}

union() {
  mug();
  handle();
}