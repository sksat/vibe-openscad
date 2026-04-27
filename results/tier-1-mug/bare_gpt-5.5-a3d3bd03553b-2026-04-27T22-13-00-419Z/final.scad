$fn = 128;

outer_d = 80;
outer_r = outer_d / 2;
height = 100;
wall = 4;
bottom_thickness = 6;
inner_r = outer_r - wall;

handle_hole_r = 12;
handle_tube_r = 4;
handle_major_r = handle_hole_r + handle_tube_r;
handle_center_x = outer_r + handle_major_r + handle_tube_r - 1;
handle_center_z = height / 2;

module cup_body() {
    difference() {
        cylinder(h = height, r = outer_r);
        translate([0, 0, bottom_thickness])
            cylinder(h = height + 1, r = inner_r);
    }
}

module torus(major_r, tube_r) {
    rotate_extrude(convexity = 10)
        translate([major_r, 0, 0])
            circle(r = tube_r, $fn = 48);
}

module handle() {
    union() {
        translate([handle_center_x, 0, handle_center_z])
            rotate([90, 0, 0])
                torus(handle_major_r, handle_tube_r);

        for (zpos = [
            handle_center_z - handle_major_r,
            handle_center_z + handle_major_r
        ]) {
            translate([outer_r - 1, 0, zpos])
                rotate([0, 90, 0])
                    cylinder(
                        h = handle_center_x - (outer_r - 1),
                        r = handle_tube_r
                    );
        }
    }
}

union() {
    cup_body();
    handle();
}