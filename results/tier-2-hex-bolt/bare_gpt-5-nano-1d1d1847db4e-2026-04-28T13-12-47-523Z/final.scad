R = 13 / sqrt(3);
head_height = 5.3;
shank_length = 30;
shank_radius = 4;

module hex_head() {
  pts = [
    [ R, 0 ],
    [ R * 0.5, R * 0.8660254037844386 ],
    [ -R * 0.5, R * 0.8660254037844386 ],
    [ -R, 0 ],
    [ -R * 0.5, -R * 0.8660254037844386 ],
    [ R * 0.5, -R * 0.8660254037844386 ]
  ];
  linear_extrude(height = head_height)
    polygon(points = pts);
}

union() {
  // Head: bottom at z = 0, top at z = head_height
  hex_head();
  // Shank: top at z = 0, extends to z = -shank_length
  translate([0, 0, -shank_length])
    cylinder(h = shank_length, r = shank_radius, $fn = 60);
}