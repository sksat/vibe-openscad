// Parameters
$fn = 96;

mug_od = 80;
mug_id = 70;
mug_h  = 90;
mug_bottom = 6;

handle_inner_w = 25; // inner D width (X) = 25 mm
handle_inner_h = 30; // inner D height (Z) = 30 mm
handle_wall_t  = 5;  // uniform wall thickness around inner D
handle_depth_y = 36; // thickness along Y (tangential)
handle_gap     = 0.5; // clearance between mug outer surface (R=40) and handle inner flat

// Mug body: outer cylinder minus inner cavity (leaving 6mm bottom)
module mug_body(od, id, h, bottom) {
    difference() {
        cylinder(d = od, h = h);
        translate([0, 0, bottom])
            cylinder(d = id, h = h - bottom + 0.02); // tiny extra to ensure open top
    }
}

// 2D inner D shape in XY-plane: X=radial, Y=vertical (will map to Z after rotation)
module d2d_inner(iw, ih) {
    r = ih/2;          // semicircle radius
    d = iw - r;        // rectangle width to make D profile
    intersection() {
        // Keep half-plane x >= 0
        translate([250, 0]) square([500, 500], center = true);
        union() {
            // rectangle from x=0..d, y=-r..r
            translate([d/2, 0]) square([d, ih], center = true);
            // semicircle (circle) on the right
            translate([d, 0]) circle(r = r);
        }
    }
}

// Handle: create 3D by extruding the 2D D profile along Z, then rotate to make extrusion along Y
module handle(iw, ih, wall_t, depth_y, mug_outer_r, z_center, gap) {
    // Place so INNER flat of the D sits at mug_outer_r + gap (clearance),
    // and OUTER flat embeds into the mug by wall_t - gap (<= wall_t), ensuring a solid union.
    dx = mug_outer_r + gap;

    translate([dx, 0, z_center])
        rotate([-90, 0, 0]) // Z(extrude) -> Y, Y(2D) -> -Z
            difference() {
                // Outer D: offset the inner D by wall thickness in 2D, then extrude along Z
                linear_extrude(height = depth_y, center = true)
                    offset(delta = wall_t) d2d_inner(iw, ih);
                // Subtract inner D to form the handle hole
                linear_extrude(height = depth_y + 0.4, center = true) // a bit taller for clean subtraction
                    d2d_inner(iw, ih);
            }
}

union() {
    mug_body(mug_od, mug_id, mug_h, mug_bottom);
    handle(handle_inner_w, handle_inner_h, handle_wall_t, handle_depth_y, mug_od/2, mug_h/2, handle_gap);
}