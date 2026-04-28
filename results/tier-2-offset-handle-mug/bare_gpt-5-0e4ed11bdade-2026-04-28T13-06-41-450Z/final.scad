// Parameters
$fn = 128;

// Mug dimensions
R_outer = 40;      // Outer radius (80mm diameter)
R_inner = 35;      // Inner radius (70mm diameter)
H = 90;            // Height
B = 6;             // Bottom thickness

// Handle parameters
t = 6;             // Handle wall thickness around inner void
inner_w = 25;      // Inner void width (X direction)
inner_h = 30;      // Inner void height (Z direction)
handle_y_thick = 18; // Handle thickness along Y
eps = 1.0;         // Overlap into mug for solid union
zc = H/2;          // Z center of handle
x0 = R_outer + t - eps; // Left edge (X) of inner void

module mug_body() {
  difference() {
    // Outer shell
    cylinder(h=H, r=R_outer);
    // Inner cavity (leaves bottom thickness B)
    translate([0,0,B]) cylinder(h=H-B, r=R_inner);
  }
}

module handle() {
  // Build 2D D-shaped profile in XY plane (Y corresponds to Z),
  // then extrude along Z and rotate to make extrusion along Y.
  rotate([-90,0,0])
    linear_extrude(height=handle_y_thick, center=true, convexity=10)
      difference() {
        // Outer D shape: rectangle + semicircle cap
        union() {
          translate([x0 - t, zc - (inner_h/2 + t)])
            square([inner_w + 2*t, inner_h + 2*t], center=false);
          translate([x0 + inner_w + t, zc])
            circle(r=inner_h/2 + t);
        }
        // Inner rectangular void (25 x 30)
        translate([x0, zc - inner_h/2])
          square([inner_w, inner_h], center=false);
      }
}

union() {
  mug_body();
  handle(); // Positioned on +X side by construction
}