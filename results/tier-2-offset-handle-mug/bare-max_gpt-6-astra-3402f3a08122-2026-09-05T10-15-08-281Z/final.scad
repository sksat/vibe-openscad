$fn = 192;

outer_diameter = 80;
inner_diameter = 70;
mug_height = 90;
bottom_thickness = 6;

opening_height = 30;
opening_width = 25;
handle_depth = 12;

handle_overlap = 3;
opening_clearance = 1;
handle_outer_wall = 6;

handle_x = outer_diameter / 2 - handle_overlap;
handle_spine = handle_overlap + opening_clearance;
handle_outer_radius = handle_spine + opening_width + handle_outer_wall;

eps = 0.1;

// 2D の +X 側半楕円。rx == ry の場合は半円。
module positive_x_half_ellipse(rx, ry) {
    intersection() {
        scale([rx, ry])
            circle(r = 1);

        translate([0, -ry - eps])
            square([rx + eps, 2 * ry + 2 * eps]);
    }
}

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

module d_handle() {
    // XZ 平面に配置し、Y 方向に厚みを持たせる。
    // 本体側の直線部分を外壁に 3 mm 食い込ませる。
    translate([handle_x, 0, mug_height / 2])
        rotate([90, 0, 0])
            linear_extrude(
                height = handle_depth,
                center = true,
                convexity = 10
            )
                difference() {
                    // 外周：+X 側が半円、本体側が直線。
                    positive_x_half_ellipse(
                        handle_outer_radius,
                        handle_outer_radius
                    );

                    // 開口：幅 25 mm × 高さ 30 mm。
                    // 全体を本体外周より外側に置き、空間を確保する。
                    translate([handle_spine, 0])
                        positive_x_half_ellipse(
                            opening_width,
                            opening_height / 2
                        );
                }
}

render(convexity = 10)
    union() {
        mug_body();
        d_handle();
    }