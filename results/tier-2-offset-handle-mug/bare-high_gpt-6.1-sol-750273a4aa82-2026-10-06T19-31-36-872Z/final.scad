$fn = 180;

outer_diameter = 80;
inner_diameter = 70;
mug_height = 90;
bottom_thickness = 6;

handle_inner_width = 25;
handle_inner_height = 30;
handle_depth = 10;
handle_outer_thickness = 6;
handle_overlap = 3;

eps = 0.05;

body_radius = outer_diameter / 2;
handle_center_z = mug_height / 2;
handle_root_x = body_radius - handle_overlap;

// 外側を半円にし、開口部の幅25mm・高さ30mmを確保する。
handle_outer_radius =
    handle_inner_width + handle_outer_thickness + handle_overlap;

module mug_body() {
    difference() {
        cylinder(d = outer_diameter, h = mug_height);

        translate([0, 0, bottom_thickness])
            cylinder(
                d = inner_diameter,
                h = mug_height - bottom_thickness + eps
            );
    }
}

module handle_profile() {
    difference() {
        // 本体側が直線、+X側が半円の外形。
        intersection() {
            translate([handle_root_x, handle_center_z])
                circle(r = handle_outer_radius);

            translate([
                handle_root_x,
                handle_center_z - handle_outer_radius - eps
            ])
                square([
                    handle_outer_radius + eps,
                    2 * handle_outer_radius + 2 * eps
                ]);
        }

        // 内側のD字開口：幅25mm、高さ30mm。
        intersection() {
            translate([body_radius, handle_center_z])
                scale([
                    handle_inner_width,
                    handle_inner_height / 2
                ])
                    circle(r = 1);

            translate([
                body_radius,
                handle_center_z - handle_inner_height / 2 - eps
            ])
                square([
                    handle_inner_width + eps,
                    handle_inner_height + 2 * eps
                ]);
        }
    }
}

module mug_handle() {
    // 2DのXY平面をXZ平面へ回し、Y方向に厚みを付ける。
    // 直線側を本体外周に3mm埋め込み、確実に接続する。
    rotate([90, 0, 0])
        linear_extrude(height = handle_depth, center = true, convexity = 10)
            handle_profile();
}

render(convexity = 10)
    union() {
        mug_body();
        mug_handle();
    }