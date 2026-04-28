// Oriented Mug with D-shaped Handle
$fn = 100;

// ----- Mug dimensions -----
outer_d          = 80;   // outer diameter
inner_d          = 70;   // inner diameter
mug_height       = 90;   // total height
bottom_thickness = 6;    // bottom wall thickness

// ----- Handle dimensions -----
handle_inner_h = 30;  // inner free height (Z)
handle_inner_w = 25;  // inner free width  (X, from mug wall outward)
handle_wall    = 6;   // handle wall thickness
handle_depth   = 15;  // handle thickness in Y (depth)

// ===============================================
// Mug body
module mug_body() {
    difference() {
        // outer shell
        cylinder(d = outer_d, h = mug_height);

        // inner cavity
        translate([0, 0, bottom_thickness])
            cylinder(d = inner_d, h = mug_height - bottom_thickness);
    }
}

// ===============================================
// Handle
module handle() {

    // 2-D inner cavity profile of handle (flat at x = 0)
    module inner_profile() {
        union() {
            // rectangle part
            translate([0, -handle_inner_h/2])
                square([handle_inner_w, handle_inner_h], center = false);

            // semicircular part
            translate([handle_inner_w, 0])
                circle(r = handle_inner_h/2);
        }
    }

    difference() {
        // ----- Outer solid of handle -----
        rotate([90, 0, 0])                               // extrude along Y
            linear_extrude(height = handle_depth, center = true)
                offset(delta = handle_wall)              // add wall thickness
                    inner_profile();

        // ----- Subtract inner cavity -----
        rotate([90, 0, 0])
            linear_extrude(height = handle_depth + 0.2, center = true)
                inner_profile();
    }
}

// ===============================================
// Assemble mug and handle (handle on +X side)
union() {
    mug_body();

    // position handle: flat side flush with mug outer surface,
    // centered vertically on mug
    translate([outer_d/2, 0, mug_height/2])
        handle();
}