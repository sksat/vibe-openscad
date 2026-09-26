module bolt() {
  // Hexagonal Head
  // Across flats = 13mm -> Circumradius = 13 / (2 * cos(30deg))
  // Head height = 5.3mm
  // Head bottom at z=0
  
  R = 13 / (2 * cos(pi / 6)); // Circumradius
  
  // Define vertices for hexagonal prism
  // Bottom face (z=0)
  points_bottom = [];
  for (i = [0 : 5]) {
    points_bottom = concat(points_bottom, [[R * cos(i * pi / 3), R * sin(i * pi / 3), 0]]);
  }
  // Top face (z=5.3)
  points_top = [];
  for (i = [0 : 5]) {
    points_top = concat(points_top, [[R * cos(i * pi / 3), R * sin(i * pi / 3), 5.3]]);
  }
  
  // Combine points
  all_points = concat(points_bottom, points_top);
  
  // Define faces for polyhedron
  // Indices: 0-5 are bottom, 6-11 are top
  faces = [];
  
  // Bottom face
  faces = concat(faces, [[0, 1, 2, 3, 4, 5]]);
  // Top face
  faces = concat(faces, [[6, 7, 8, 9, 10, 11]]);
  // Side faces
  for (i = [0 : 5]) {
    // Connect vertex i (bottom) to i (top) and i+1 (top) and i+1 (bottom)
    faces = concat(faces, [[i, i + 1, i + 1 + 6, i + 6]]);
  }
  
  // Draw hexagonal head
  translate([0, 0, 0])
  polyhedron(points = all_points, faces = faces);
  
  // Shank
  // Diameter = 8mm
  // Length = 30mm
  // Top at z=0, Bottom at z=-30
  
  translate([0, 0, -30])
  cylinder(d = 8, h = 30, center = false);
}

bolt();