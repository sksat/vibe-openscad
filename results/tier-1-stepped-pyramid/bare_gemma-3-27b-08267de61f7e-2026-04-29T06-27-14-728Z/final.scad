module pyramid(base_x, base_y, height) {
  difference() {
    cube([base_x, base_y, height]);
    if (base_x > 20 && base_y > 20) {
      translate([base_x/2 - 10, base_y/2 - 10, height])
        cube([base_x-20, base_y-20, height]);
    }
  }
}

module stacked_pyramid(base_x, base_y, height, num_layers) {
  for (i = [0:num_layers - 1]) {
    layer_x = base_x - i * 20;
    layer_y = base_y - i * 20;
    translate([base_x/2 - layer_x/2, base_y/2 - layer_y/2, i * height]) {
      cube([layer_x, layer_y, height]);
    }
  }
}

module three_layered_pyramid() {
  stacked_pyramid(60, 60, 10, 3);
}

three_layered_pyramid();