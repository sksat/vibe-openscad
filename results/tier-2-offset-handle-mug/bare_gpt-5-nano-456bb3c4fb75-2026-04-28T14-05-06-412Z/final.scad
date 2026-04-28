$fn = 60;

// Core mug dimensions
height = 90;
bottom_thickness = 6;
outer_r = 40;      // outer diameter 80 -> radius 40
inner_r = 35;      // inner diameter 70 -> radius 35

// Handle dimensions (designed to be a D-shape cross-section with inner hollow 30x25)
HANDLE_LENGTH = 60;  // extent of handle along +X from mug surface
R_OUT_HANDLE = 15;   // outer handle radius (gives 2*R_OUT_HANDLE = 30 height)
R_IN_HANDLE  = 12.5; // inner handle radius (outer radius - wall_thickness), gives inner space width 25

// Mug body: hollow cylinder (outer shell + bottom 6 mm, open top)
module mug_body() {
  difference() {
    // outer shell
    cylinder(h = height, r = outer_r, center = false);
    // hollow interior starting 6 mm above bottom
    translate([0, 0, bottom_thickness])
      cylinder(h = height - bottom_thickness, r = inner_r, center = false);
  }
}

// Helper: create a half-cylinder along X (to form a "D"-shaped cross-section when clipped and extruded)
// This produces a half-cylinder by intersecting a full cylinder with a bounding box to keep only Y >= 0 portion.
// The result has its left face at x = 0 and extends to x = HANDLE_LENGTH (in local coordinates).
module half_cylinder(h, r) {
  intersection() {
    // cylinder oriented along X by rotating a Z-oriented cylinder
    rotate([0, 90, 0])
      cylinder(h = h, r = r, center = true);
    // clip to keep only the half with Y >= 0
    // cube extends in X from 0 to h, Y from 0 to 2r, Z from 0 to 2r
    cube([h, 2*r, 2*r], center = false);
  }
}

// Handle: attach to +X side of mug (left face of handle sits at x = 40)
// Center handle vertically at mug mid-height (z = 45)
module handle() {
  dx = 40;                // left boundary aligns with mug outer surface (radius 40)
  dz = 45 - R_OUT_HANDLE; // align vertical center to z = 45
  translate([dx, 0, dz])
    difference() {
      // outer D-shaped shell (half-cylinder)
      half_cylinder(HANDLE_LENGTH, R_OUT_HANDLE);
      // inner hollow (slightly smaller half-cylinder)
      half_cylinder(HANDLE_LENGTH, R_IN_HANDLE);
    }
}

// Assemble
union() {
  mug_body();
  handle();
}