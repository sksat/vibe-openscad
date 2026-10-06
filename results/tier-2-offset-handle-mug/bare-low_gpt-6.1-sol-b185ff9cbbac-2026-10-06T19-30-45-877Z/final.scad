$fn = 160;

outer_diameter = 80;
inner_diameter = 70;
mug_height = 90;
bottom_thickness = 6;

handle_opening_width = 25;
handle_opening_height = 30;
handle_wall = 8;
handle_depth = 10;

handle_center_z = mug_height / 2;
handle_body_edge_x = outer_diameter / 2 - 2;
handle_opening_edge_x = handle_body_edge_x + handle_wall;

// +X 側へ張り出す半楕円。直線側は x = 0。
module half_ellipse(rx, rz) {
    intersection() {
        scale([rx, rz])
            circle(r = 1);

        translate([0, -rz - 1])
            square([rx + 1, 2 * rz + 2]);
    }
}

module handle_profile() {
    difference() {
        union() {
            translate([handle_opening_edge_x, 0])
                half_ellipse(
                    handle_opening_width + handle_wall,
                    handle_opening_height / 2 + handle_wall
                );

            translate([
                handle_body_edge_x,
                -handle_opening_height / 2 - handle_wall
            ])
                square([
                    handle_wall,
                    handle_opening_height + 2 * handle_wall
                ]);
        }

        translate([handle_opening_edge_x, 0])
            half_ellipse(
                handle_opening_width,
                handle_opening_height / 2
            );
    }
}

module handle() {
    translate([0, 0, handle_center_z])
        rotate([90, 0, 0])
            linear_extrude(height = handle_depth, center = true)
                handle_profile();
}

render()
difference() {
    union() {
        cylinder(d = outer_diameter, h = mug_height);
        handle();
    }

    translate([0, 0, bottom_thickness])
        cylinder(
            d = inner_diameter,
            h = mug_height - bottom_thickness + 1
        );
}