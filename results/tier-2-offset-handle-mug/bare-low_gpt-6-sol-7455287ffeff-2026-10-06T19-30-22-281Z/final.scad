$fn = 128;

outer_d = 80;
inner_d = 70;
mug_h = 90;
bottom_thickness = 6;

handle_thickness = 12;
handle_center_z = mug_h / 2;
handle_outer_radius = 32;
handle_opening_width = 25;
handle_opening_height = 30;
handle_join_x = 37;             // 本体外周に食い込ませて接続
handle_straight_x = outer_d / 2;

module mug_body() {
    difference() {
        cylinder(h = mug_h, d = outer_d);
        translate([0, 0, bottom_thickness])
            cylinder(h = mug_h - bottom_thickness + 1, d = inner_d);
    }
}

module handle_profile() {
    difference() {
        union() {
            // 本体側の直線部分
            translate([handle_join_x, handle_center_z - handle_outer_radius])
                square([
                    handle_straight_x - handle_join_x,
                    2 * handle_outer_radius
                ]);

            // +X 側だけに広がる半円
            intersection() {
                translate([handle_straight_x, handle_center_z])
                    circle(r = handle_outer_radius);
                translate([handle_straight_x,
                           handle_center_z - handle_outer_radius])
                    square([handle_outer_radius, 2 * handle_outer_radius]);
            }
        }

        // 高さ 30 mm × 幅 25 mm の指を入れる空間
        translate([handle_straight_x,
                   handle_center_z - handle_opening_height / 2])
            square([handle_opening_width, handle_opening_height]);
    }
}

union() {
    mug_body();

    translate([0, handle_thickness / 2, 0])
        rotate([90, 0, 0])
            linear_extrude(height = handle_thickness)
                handle_profile();
}