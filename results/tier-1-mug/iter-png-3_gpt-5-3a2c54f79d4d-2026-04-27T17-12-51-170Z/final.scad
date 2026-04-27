$fn = 128;

outer_d = 80;
outer_r = outer_d/2;
height  = 100;
wall    = 4;
bottom  = 6;

inner_r = outer_r - wall;

handle_R = 12;
handle_r = 4;
handle_z = height/2;
embed    = 1;

module cup_body() {
  difference() {
    cylinder(h=height, r=outer_r);
    translate([0,0,bottom]) cylinder(h=height-bottom, r=inner_r);
  }
}

module torus(R, r) {
  rotate_extrude(angle=360)
    translate([R,0,0])
      circle(r=r);
}

module handle() {
  near_x = inner_r + embed;
  c = near_x + (handle_R + handle_r);
  translate([c, 0, handle_z])
    rotate([90,0,0])
      torus(handle_R, handle_r);
}

union() {
  cup_body();
  handle();
}