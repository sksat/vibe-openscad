// Oriented mug with D-shaped handle
$fn = 128;

// ---------- Mug parameters ----------
mug_outer_d      = 80;          // mm
mug_inner_d      = 70;          // mm
mug_height       = 90;          // mm
bottom_thickness = 6;           // mm
wall_thickness   = (mug_outer_d - mug_inner_d) / 2;   // 5 mm

// ---------- Handle parameters ----------
handle_open_h = 30;             // inner void height (Z)
handle_open_w = 25;             // inner void radial width (X)
handle_wall   = wall_thickness; // thickness around void (5 mm)
handle_depth  = 15;             // thickness in Y

// Derived
handle_outer_h = handle_open_h + 2*handle_wall;       // 40
handle_inner_r = handle_open_h / 2;                   // 15
handle_outer_r = handle_outer_h / 2;                  // 20

// ---------- Modules ----------
module mug_body(){
    difference(){
        cylinder(h = mug_height, r = mug_outer_d/2);
        translate([0,0,bottom_thickness])
            cylinder(h = mug_height - bottom_thickness, r = mug_inner_d/2);
    }
}

// Outer 2-D D-shape (full handle cross-section)
module handle_outer_2d(){
    union(){
        // straight side against mug
        translate([0, -handle_outer_h/2])
            square([handle_outer_r, handle_outer_h]);
        // curved outer side
        translate([handle_outer_r, 0])
            circle(r = handle_outer_r);
    }
}

// Inner 2-D void to create finger space
module handle_inner_2d(){
    union(){
        // rectangular part of void
        translate([handle_wall, -handle_open_h/2])
            square([handle_open_w - handle_inner_r, handle_open_h]);
        // semicircular part of void
        translate([handle_wall + handle_open_w - handle_inner_r, 0])
            circle(r = handle_inner_r);
    }
}

module handle(){
    // Build 3-D handle by extruding the 2-D profile,
    // then rotate so Z is vertical and Y is handle depth
    rotate([90,0,0])
        linear_extrude(height = handle_depth, center = true)
            difference(){
                handle_outer_2d();
                handle_inner_2d();
            }
}

// ---------- Assembly ----------
union(){
    // Mug body
    mug_body();

    // Handle on +X side, centered vertically
    translate([mug_outer_d/2 - 0.01, 0, (mug_height - handle_outer_h)/2])
        handle();
}