// Mug with oriented D-shaped handle ( +X direction )

$fn = 100;                        // resolution for round parts

// ------- Mug parameters -------
outer_d   = 80;                   // outer diameter
inner_d   = 70;                   // inner diameter
height    = 90;                   // total height
bottom_th = 6;                    // bottom thickness
wall_th   = (outer_d - inner_d)/2; // side wall thickness (5 mm)

// ------- Handle parameters -------
handle_inner_h = 30;              // inner height (Z)
handle_inner_w = 25;              // inner width (Y)
handle_wall    = wall_th;         // handle wall thickness

handle_h   = handle_inner_h + 2*handle_wall;            // total handle height
outer_r    = handle_inner_w/2 + handle_wall;            // outer semicircle radius
inner_r    = outer_r - handle_wall;                     // inner semicircle radius
offset_x   = handle_wall;                               // flat-side thickness

fudge = 0.01; // tiny overlap to guarantee union

// ------- 2D D-shape generator -------
module Dshape(r, off){
    union(){
        // flat-side rectangle
        translate([0, -r]) square([off, 2*r], center=false);
        // semicircle (only x >= 0 half)
        intersection(){
            translate([off, 0]) circle(r=r);
            translate([0, -r]) square([2*r + off, 2*r], center=false);
        }
    }
}

// ------- Mug body -------
module mug(){
    difference(){
        cylinder(d=outer_d, h=height);                           // outer shell
        translate([0, 0, bottom_th])
            cylinder(d=inner_d, h=height - bottom_th);           // inner cavity
    }
}

// ------- Handle -------
module handle(){
    difference(){
        // outer volume
        linear_extrude(height=handle_h, convexity=10)
            Dshape(outer_r, offset_x);
        // inner void
        translate([0, 0, handle_wall])
            linear_extrude(height=handle_inner_h, convexity=10)
                Dshape(inner_r, offset_x + handle_wall);
    }
}

// ------- Assembly -------
union(){
    mug();
    translate([outer_d/2 - fudge, 0, (height - handle_h)/2])
        handle();
}