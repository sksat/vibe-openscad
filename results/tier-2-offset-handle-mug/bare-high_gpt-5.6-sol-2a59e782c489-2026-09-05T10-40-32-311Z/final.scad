$fn = 128;

cup_outer_diameter = 80;
cup_inner_diameter = 70;
cup_height         = 90;
bottom_thickness   = 6;

handle_center_z = cup_height / 2;
handle_depth    = 14;

// 内側空間: 高さ30mm × 幅25mm
inner_flat_x    = 42;
inner_width     = 25;
inner_half_h    = 15;

// 外側D形状
outer_flat_x    = 36;
outer_width     = 37;
outer_half_h    = 21;

profile_steps = 96;

module d_profile(flat_x, width, half_height, center_z) {
    polygon(
        points = concat(
            [[flat_x, center_z - half_height]],
            [
                for (a = [-90 : 180 / profile_steps : 90])
                    [
                        flat_x + width * cos(a),
                        center_z + half_height * sin(a)
                    ]
            ],
            [[flat_x, center_z + half_height]]
        )
    );
}

module mug_body() {
    difference() {
        cylinder(
            h = cup_height,
            d = cup_outer_diameter
        );

        translate([0, 0, bottom_thickness])
            cylinder(
                h = cup_height - bottom_thickness + 0.2,
                d = cup_inner_diameter
            );
    }
}

module handle() {
    rotate([90, 0, 0])
        linear_extrude(
            height = handle_depth,
            center = true,
            convexity = 10
        )
            difference() {
                d_profile(
                    outer_flat_x,
                    outer_width,
                    outer_half_h,
                    handle_center_z
                );

                d_profile(
                    inner_flat_x,
                    inner_width,
                    inner_half_h,
                    handle_center_z
                );
            }
}

union() {
    mug_body();
    handle();
}