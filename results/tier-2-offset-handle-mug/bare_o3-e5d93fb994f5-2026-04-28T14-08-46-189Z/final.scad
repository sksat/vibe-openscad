// Mug with oriented handle
$fn = 128;

// ----------------- Parameters -----------------
mug_outer_d       = 80;   // mm
mug_inner_d       = 70;   // mm
mug_height        = 90;   // mm
bottom_thickness  = 6;    // mm

handle_inner_h    = 30;   // mm (vertical opening)
handle_inner_w    = 25;   // mm (radial opening)
handle_wall       = 5;    // mm (handle thickness)
handle_depth      = 15;   // mm (depth along Y)

// ------------------------------------------------
mug_outer_r  = mug_outer_d/2;
mug_inner_r  = mug_inner_d/2;

handle_outer_h = handle_inner_h + 2*handle_wall;   // 40 mm
handle_outer_r = handle_outer_h/2;                 // 20 mm
handle_inner_r = handle_inner_h/2;                 // 15 mm

// ----------------- Modules -----------------
module mug_body(){
    difference(){
        cylinder(h = mug_height, r = mug_outer_r, center = false);
        translate([0,0,bottom_thickness])
            cylinder(h = mug_height - bottom_thickness, r = mug_inner_r, center = false);
    }
}

module handle_outer_2d(){
    union(){
        // semicircle
        translate([handle_outer_r,0])
            circle(r = handle_outer_r);
        // rectangle joining to straight side
        translate([0,-handle_outer_r])
            square([handle_outer_r, handle_outer_h]);
    }
}

module handle_inner_2d(){
    union(){
        translate([handle_wall + handle_inner_r,0])
            circle(r = handle_inner_r);
        translate([handle_wall,-handle_inner_r])
            square([handle_inner_r, handle_inner_h]);
    }
}

module handle(){
    // Build 2D D-shape and extrude, then rotate so Z is vertical
    rotate([90,0,0])
        linear_extrude(height = handle_depth, center = true)
            difference(){
                handle_outer_2d();
                handle_inner_2d();
            }
}

// ----------------- Assembly -----------------
union(){
    mug_body();
    // Position handle on +X side, centered in height
    translate([mug_outer_r - 0.01, 0, mug_height/2])
        handle();
}