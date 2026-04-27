$fn = 128;

outer_d = 80;     // 外径
height  = 100;    // 高さ
wall    = 4;      // 肉厚
bottom  = 6;      // 底厚

handle_R = 12;    // 取手（リング）の半径
handle_r = 4;     // 取手の太さ（断面半径）
eps = 0.6;        // カップと取手を確実に接合するためのめり込み量

module cup() {
  difference() {
    cylinder(h = height, r = outer_d/2);
    translate([0, 0, bottom])
      cylinder(h = height - bottom, r = outer_d/2 - wall);
  }
}

module torus_y(R, r) {
  rotate([90, 0, 0])
    rotate_extrude(angle = 360)
      translate([R, 0, 0]) circle(r = r);
}

union() {
  cup();
  translate([outer_d/2 + (handle_R + handle_r) - eps, 0, height/2])
    torus_y(handle_R, handle_r);
}