$fn = 256;

body_od = 80;
body_id = 70;
body_h = 90;
bottom_t = 6;

handle_zc = 45;
handle_y = 20;
handle_mat = 6;
void_h = 30;
void_w = 25;

body_r = body_od / 2;
overlap = 4;
outer_x0 = body_r - overlap;
void_x0 = outer_x0 + handle_mat;
outer_h = void_h + 2 * handle_mat;
outer_w = void_w + 2 * handle_mat;

function d_points(x0, w, h, n = 128) =
  let(r = h / 2, cx = x0 + (w - r))
  concat(
    [[x0, -r], [x0, r], [cx, r]],
    concat(
      [for (i = [1:n-1]) [cx + r * cos(90 - i * 180 / n), r * sin(90 - i * 180 / n)]],
      [[cx, -r]]
    )
  );

module d_shape(x0, w, h, n = 128) {
  polygon(points = d_points(x0, w, h, n), convexity = 1);
}

module d_prism(x0, w, h, ylen, zc, n = 128) {
  translate([0, 0, zc])
  rotate([90, 0, 0])
  linear_extrude(height = ylen, center = true)
    d_shape(x0, w, h, n);
}

module handle() {
  difference() {
    d_prism(outer_x0, outer_w, outer_h, handle_y, handle_zc);
    d_prism(void_x0, void_w, void_h, handle_y + 2, handle_zc);
  }
}

module mug_body() {
  difference() {
    cylinder(d = body_od, h = body_h, $fn = 256);
    translate([0, 0, bottom_t])
      cylinder(d = body_id, h = body_h - bottom_t + 1, $fn = 256);
  }
}

union() {
  mug_body();
  handle();
}