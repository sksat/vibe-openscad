// mug with specified handle on +X side
outer_d = 80;
inner_d = 70;
height = 90;
bottom_thickness = 6;
opening_width = 25;
opening_height = 30;
handle_thickness = 15;
$fn = 100;

union() {
  // mug body
  difference() {
    cylinder(d = outer_d, h = height);
    translate([0, 0, bottom_thickness])
      cylinder(d = inner_d, h = height - bottom_thickness);
  }
  // handle
  translate([0, 0, height/2 - opening_height/2])
    linear_extrude(height = opening_height)
      union() {
        // flat side of D
        translate([outer_d/2 + opening_width, -handle_thickness])
          square([handle_thickness, 2*handle_thickness]);
        // semicircular outer side
        intersection() {
          translate([outer_d/2 + opening_width + handle_thickness, 0])
            circle(r = handle_thickness);
          translate([outer_d/2 + opening_width + handle_thickness/2, 0])
            square([handle_thickness, 2*handle_thickness], center = true);
        }
      }
}