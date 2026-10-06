$fn = 128;

outer_diameter = 80;
inner_diameter = 70;
mug_height = 90;
base_thickness = 6;

handle_thickness = 12;  // Y方向の厚み
handle_center_z = mug_height / 2;
handle_attach_x = 38;   // 本体に重ねて確実に接続

// D字の外形：本体側は直線、外側は半円
outer_arc_x = 50.5;
outer_arc_radius = 25;

// 指を入れる開口：高さ30mm、X方向の幅25mm
opening_height = 30;
opening_width = 25;
opening_left_x = 43;
inner_arc_radius = opening_height / 2;
inner_arc_x = opening_left_x + opening_width - inner_arc_radius;

module d_profile(left_x, arc_x, center_z, radius, steps = 96) {
    polygon(points = concat(
        [[left_x, center_z - radius]],
        [for (i = [0 : steps])
            [arc_x + radius * cos(-90 + 180 * i / steps),
             center_z + radius * sin(-90 + 180 * i / steps)]],
        [[left_x, center_z + radius]]
    ));
}

module mug_body() {
    difference() {
        cylinder(d = outer_diameter, h = mug_height);
        translate([0, 0, base_thickness])
            cylinder(d = inner_diameter,
                     h = mug_height - base_thickness + 1);
    }
}

module handle() {
    rotate([90, 0, 0])
        linear_extrude(height = handle_thickness, center = true, convexity = 10)
            difference() {
                d_profile(handle_attach_x, outer_arc_x,
                          handle_center_z, outer_arc_radius);
                d_profile(opening_left_x, inner_arc_x,
                          handle_center_z, inner_arc_radius);
            }
}

union() {
    mug_body();
    handle();
}