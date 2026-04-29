// M8 六角ボルト (ねじ山省略)

module hexagon_head(across_flats, height) {
  radius = across_flats / 2;
  polygon_points = [];
  for (i = [0:5]) {
    angle = i * 60;
    x = radius * cos(angle);
    y = radius * sin(angle);
    polygon_points.push([x, y]);
  }

  linear_extrude(height)
    polygon(polygon_points);
}

module bolt(across_flats, head_height, shank_diameter, shank_length) {
  difference() {
    union() {
      hexagon_head(across_flats, head_height);
      translate([0, 0, -shank_length])
        cylinder(h = shank_length, r = shank_diameter / 2);
    }
    // 必要に応じて、シャンクの端に面取りを追加できます。
  }
}

bolt(across_flats = 13, head_height = 5.3, shank_diameter = 8, shank_length = 30);