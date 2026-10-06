$fn = 128;

// マグ本体
cup_outer_diameter = 80;
cup_inner_diameter = 70;
cup_height = 90;
bottom_thickness = 6;

// 取手
handle_thickness = 12;
handle_center_z = cup_height / 2;
outer_chord_x = 37;
outer_radius = 35;

// 取手の内側空間：幅25mm × 高さ30mm
opening_left_x = 42;
opening_round_start_x = 52;
opening_radius = 15;

module cup_body() {
    difference() {
        cylinder(d = cup_outer_diameter, h = cup_height);

        translate([0, 0, bottom_thickness])
            cylinder(
                d = cup_inner_diameter,
                h = cup_height - bottom_thickness + 1
            );
    }
}

module handle_profile_2d() {
    difference() {
        polygon(points = concat(
            [[outer_chord_x, -outer_radius]],
            [
                for (a = [-90 : 2 : 90])
                    [
                        outer_chord_x + outer_radius * cos(a),
                        outer_radius * sin(a)
                    ]
            ],
            [[outer_chord_x, outer_radius]]
        ));

        polygon(points = concat(
            [[opening_left_x, -opening_radius]],
            [[opening_round_start_x, -opening_radius]],
            [
                for (a = [-90 : 2 : 90])
                    [
                        opening_round_start_x + opening_radius * cos(a),
                        opening_radius * sin(a)
                    ]
            ],
            [[opening_left_x, opening_radius]]
        ));
    }
}

union() {
    cup_body();

    translate([0, 0, handle_center_z])
        rotate([90, 0, 0])
            linear_extrude(height = handle_thickness, center = true)
                handle_profile_2d();
}