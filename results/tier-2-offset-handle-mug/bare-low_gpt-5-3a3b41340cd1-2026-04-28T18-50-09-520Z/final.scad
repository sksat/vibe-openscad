// Parameters
outer_d = 80;        // outer diameter (mm)
inner_d = 70;        // inner diameter (mm)
height  = 90;        // mug height (mm)
bottom_thick = 6;    // bottom thickness (mm)
r_outer = outer_d/2;
r_inner = inner_d/2;

// Handle parameters
handle_inner_w = 25; // inner space width (mm)
handle_inner_h = 30; // inner space height (mm)
handle_thick   = 5;  // ring thickness around inner space (mm)
handle_depth   = 16; // extrusion depth along Y (mm)
z_mid = height/2;    // center height

// Construct mug with handle and inner cavity
difference() {
  // Solid: body + handle
  union() {
    // Mug outer solid
    cylinder(h=height, r=r_outer, $fn=128);

    // D-shaped handle on +X side
    // Build 2D profile in X-Y (Y used as Z), then extrude along Z and rotate to Y
    // Ensure strong union by intruding flat side slightly into the mug (x0 < r_outer)
    handle_2d_zmid(z_mid);
  }

  // Hollow interior (leaves 6mm bottom)
  translate([0,0,bottom_thick])
    cylinder(h=height - bottom_thick, r=r_inner, $fn=128);
}

// Handle module
module handle_2d_zmid(zc) {
  H  = handle_inner_h + 2*handle_thick;  // outer D height
  R  = H/2;                               // radius for semicircle
  x0 = r_outer - 6;                       // flat side position (slightly inside mug to ensure union)
  rectW = handle_inner_w + 2*handle_thick;

  // 2D D-shape in X-Y (Y corresponds to Z), then extrude along Z and rotate to Y
  rotate([90,0,0])  // Z -> -Y
    linear_extrude(height=handle_depth, center=true, convexity=10)
      difference() {
        union() {
          // Flat section
          square([rectW, H], center=false)
            translate([x0, zc - H/2]);

          // Semicircular outer end
          translate([x0 + rectW + R, zc])
            circle(r=R, $fn=96);
        }
        // Inner opening (rectangular void)
        translate([x0 + handle_thick, zc - handle_inner_h/2])
          square([handle_inner_w, handle_inner_h], center=false);
      }
}