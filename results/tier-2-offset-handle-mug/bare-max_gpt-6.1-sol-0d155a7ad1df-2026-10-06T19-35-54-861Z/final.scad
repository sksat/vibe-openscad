$fn = 160;

outer_diameter = 80;
inner_diameter = 70;
mug_height = 90;
bottom_thickness = 6;

handle_open_width = 25;
handle_open_height = 30;
handle_wall = 5;
handle_depth = 10;
handle_overlap = 3;

handle_root_x = outer_diameter / 2 - handle_overlap;
handle_center_z = mug_height / 2;

epsilon = 0.1;

// 本体側が直線、外側の円弧が半円の D 字断面。
module d_profile(width, height) {
    radius = height / 2;
    straight_length = width - radius;

    intersection() {
        union() {
            translate([0, -radius])
                square([straight_length, height]);

            translate([straight_length, 0])
                circle(r = radius);
        }

        translate([0, -radius])
            square([width, height]);
    }
}

module mug_body() {
    difference() {
        cylinder(d = outer_diameter, h = mug_height);

        translate([0, 0, bottom_thickness])
            cylinder(
                d = inner_diameter,
                h = mug_height - bottom_thickness + epsilon
            );
    }
}

module mug_handle() {
    // XZ 平面に配置し、+X 側の外壁へ 3mm 食い込ませる。
    translate([handle_root_x, 0, handle_center_z])
        rotate([90, 0, 0])
            linear_extrude(
                height = handle_depth,
                center = true,
                convexity = 10
            )
                difference() {
                    d_profile(
                        handle_open_width + 2 * handle_wall,
                        handle_open_height + 2 * handle_wall
                    );

                    translate([handle_wall, 0])
                        d_profile(
                            handle_open_width,
                            handle_open_height
                        );
                }
}

union() {
    mug_body();
    mug_handle();
}