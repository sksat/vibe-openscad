// Parameters
outer_diameter = 80;
inner_diameter = 70;
height = 90;
wall_thickness = (outer_diameter - inner_diameter) / 2;
bottom_thickness = 6;

handle_inner_height = 30;
handle_inner_width = 25;
handle_wall = 5;
handle_depth = 12;
handle_overlap = 1; // how much to embed into the mug wall
$fn = 100;

// Mug body
module mug_body() {
    difference() {
        cylinder(h = height, r = outer_diameter / 2);
        translate([0, 0, bottom_thickness])
            cylinder(h = height - bottom_thickness, r = inner_diameter / 2);
    }
}

// 2D D-shape for handle in the X (radial) and Y (vertical) plane, centered vertically
module handle_shape2d() {
    outer_h = handle_inner_height + 2 * handle_wall;
    outer_w = handle_inner_width + 2 * handle_wall;
    outer_r = outer_h / 2;
    inner_h = handle_inner_height;
    inner_w = handle_inner_width;
    inner_r = inner_h / 2;
    difference() {
        // Outer D shape
        union() {
            translate([0, -outer_h / 2])
                square([outer_w - outer_r, outer_h], center = false);
            translate([outer_w - outer_r, 0])
                circle(r = outer_r);
        }
        // Inner void
        union() {
            translate([0, -inner_h / 2])
                square([inner_w - inner_r, inner_h], center = false);
            translate([inner_w - inner_r, 0])
                circle(r = inner_r);
        }
    }
}

// Handle 3D
module handle() {
    translate([outer_diameter / 2 - handle_overlap, 0, height / 2])
        rotate([-90, 0, 0]) // orient so extrusion goes along global Y
            linear_extrude(height = handle_depth, center = true, convexity = 10)
                handle_shape2d();
}

// Assemble mug and handle
union() {
    mug_body();
    handle();
}