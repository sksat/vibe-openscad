$fn = 128;

mug_outer_d = 80;
mug_inner_d = 70;
mug_height = 90;
bottom_thickness = 6;

handle_depth = 14;       // Y方向の厚み
handle_z = mug_height / 2;

// 取手の外形：本体側が直線、外側が半円
outer_flat_x = mug_outer_d / 2 - 3;  // 本体に3mm食い込ませる
outer_arc_x = mug_outer_d / 2 + 11;
outer_radius = 24;

// 内側の空間：高さ30mm、幅25mm
inner_radius = 15;
inner_arc_x = mug_outer_d / 2 + 12;
inner_flat_x = inner_arc_x - (25 - inner_radius);

module d_profile(flat_x, arc_x, radius, center_z) {
    polygon(points = concat(
        [[flat_x, center_z - radius]],
        [for (a = [-90:3:90])
            [arc_x + radius * cos(a),
             center_z + radius * sin(a)]],
        [[flat_x, center_z + radius]]
    ));
}

module mug_body() {
    difference() {
        cylinder(d = mug_outer_d, h = mug_height);
        translate([0, 0, bottom_thickness])
            cylinder(
                d = mug_inner_d,
                h = mug_height - bottom_thickness + 1
            );
    }
}

module handle() {
    rotate([90, 0, 0])
        linear_extrude(height = handle_depth, center = true)
            difference() {
                d_profile(outer_flat_x, outer_arc_x,
                          outer_radius, handle_z);
                d_profile(inner_flat_x, inner_arc_x,
                          inner_radius, handle_z);
            }
}

union() {
    mug_body();
    handle();
}