// Mug with handle (OpenSCAD)

$fn = 128;

// Parameters
outer_d = 80;      // outer diameter
inner_d = 70;      // inner diameter
t_wall  = 5;       // wall thickness (given)
h_mug   = 90;      // mug height
t_bottom= 6;       // bottom thickness

handle_w = 25;     // inner space width (x-direction)
handle_h = 30;     // inner space height (z-direction)
handle_center_z = h_mug/2; // center near mid height

handle_thickness = 5; // approximate handle wall thickness (for solidness)
handle_outer_r = handle_h/2; // radius used for outer half-cylinder

module mug() {
  difference() {
    // Outer cylinder with bottom thickness included
    cylinder(d=outer_d, h=h_mug, center=false);

    // Inner cavity: leave bottom thickness
    translate([0,0,t_bottom])
      cylinder(d=inner_d, h=h_mug - t_bottom, center=false);
  }
}

module handle() {
  // D-shaped handle:
  // - Outside: half-cylinder along YZ plane (flat side toward mug center)
  // - Inside: remove a slightly smaller half-cylinder to make an opening with
  //            inner cross-section approximating 30mm(height) x 25mm(width)
  //
  // We'll place the handle on +X side only.
  // Coordinate note:
  // - Mug axis: Z
  // - We attach handle so it extends in +X direction.
  // - Half-cylinder is generated along Y (so width is along Y) and radius is Z.

  // Choose radius so that inner height matches ~handle_h
  r_outer = handle_outer_r; // ~ handle_h/2
  r_inner = r_outer - handle_thickness;

  // Depth (along Y) is handle_w, using half-cylinder which naturally spans 2*r.
  // We'll limit width by intersecting with a Y slab of size handle_w.
  // Also, orient the half-cylinder so its flat side is toward -X (mug center),
  // and its curved side is toward +X.

  // Position: touch at mug outer surface on +X
  mug_r = outer_d/2;

  // Half-cylinder centered in Y at 0.
  // Flat side aligned so that curved outer surface is at +X near mug surface.
  // We'll create half-cylinder with centerline at X = mug_r.
  x_attach = mug_r; // flat face starts at X=mug_r, curved extends to +X.

  translate([x_attach, 0, handle_center_z])
    rotate([0,90,0])  // make cylinder axis along X initially, then adjust to half-cylinder along X
      // We'll build using a half-cylinder via intersection with a half-space.
      difference() {
        // Outer half-cylinder (curved outer, flat inner side)
        intersection() {
          // Full cylinder (axis along X after rotate)
          rotate([0,0,0])
            translate([0,0,0])
              cylinder(r=r_outer, h=outer_d*0.4, center=false);

          // Keep only the +X half of the cylinder relative to its center
          // For a cylinder (axis along X), half selection is in YZ, not X.
          // Instead, we create "D" in cross-section by selecting Y range:
          // - The flat side is created by clipping on Y: keep Y >= 0 for half.
          translate([0, -r_outer, -r_outer])
            cube([outer_d*0.4, 2*r_outer, 2*r_outer], center=false);
        }

        // Inner cavity in the handle: subtract smaller half-cylinder
        intersection() {
          cylinder(r=r_inner, h=outer_d*0.4, center=false);

          translate([0, -r_inner, -r_inner])
            cube([outer_d*0.4, 2*r_inner, 2*r_inner], center=false);
        }

        // Limit the overall handle width (inner space target ~handle_w) by slicing in Y.
        // (Applied after subtraction; keeps walls from extending too far.)
        translate([0, -(handle_w/2 + handle_thickness), -(r_outer)])
          cube([outer_d*0.4, handle_w + 2*handle_thickness, 2*r_outer], center=false);
      }
}

module handle_v2() {
  // More controlled D-shape:
  // Create a "D" cross-section in YZ, extruded along X into the +X side,
  // then subtract an inner opening with the requested width/height.
  //
  // D-shape in 2D: outer half-circle + flat line.
  // We use rotate_extrude-like by using linear_extrude of 2D polygons.

  mug_r = outer_d/2;

  // X extrusion length: make sure it grips the mug wall firmly
  x_len = 20;

  // 2D coordinates:
  // - Flat side is at X=0 in 2D space; curved side extends to +Y.
  // But for our 2D, we will define in (y,z) plane.
  // Let half-circle be centered at y = 0, z = 0? Better:
  // Define 2D in (Y,Z):
  // outer half-circle radius r_outer centered at (Y=0, Z=0),
  // keep only Y>=0 to form the D with flat at Y=0.
  r_outer = handle_h/2;
  r_inner = r_outer - handle_thickness;

  // Width control: inner opening width is handle_w (in Y).
  // We'll subtract an inner half-oval limited to handle_w in Y by clipping.
  // Then outer will be clipped similarly to avoid overly long width.

  linear_extrude(height=x_len)
    translate([mug_r, 0, handle_center_z])  // move to mug side and height
      rotate([0,0,0])  // keep
      // Build outer D in YZ (extruded along X)
      difference() {
        // Outer D polygon (in YZ plane)
        // Outer half-circle from z=-r_outer..+r_outer with y>=0
        polygon(concat(
          // Arc points (counter-clockwise), y from 0..r
          [for (i=[0:60]) 
            let(t = -90 + i*(180/60))
            [ r_outer*cos(t), r_outer*sin(t) ]],
          // Close with flat edge along y=0 from top to bottom
          [[0, r_outer],[0,-r_outer]]
        ));

        // Inner opening: subtract smaller D, clipped by requested inner width in Y
        translate([0,0])
          intersection() {
            // Inner D
            polygon(concat(
              [for (i=[0:60])
                let(t = -90 + i*(180/60))
                [ r_inner*cos(t), r_inner*sin(t) ]],
              [[0, r_inner],[0,-r_inner]]
            ));
            // Clip to requested inner width around y= (0..handle_w)
            // Since D uses y>=0, we only keep 0..handle_w.
            translate([0,0])
              square([handle_w, 2*r_outer + 1], center=false);
          }
      }
}

module mug_with_handle() {
  union() {
    mug();

    // Attach handle only on +X side:
    // The handle geometry is placed at X = mug outer radius.
    // Ensure it overlaps slightly into the mug wall region to avoid gaps.
    // We'll union by overlapping in X by a small amount.
    translate([0,0,0])
      union() {
        // Choose handle_v2 for controlled D shape.
        // Slight negative X offset to guarantee connection (overlap) with mug wall.
        translate([-1, 0, 0]) handle_v2();
      }
  }
}

mug_with_handle();